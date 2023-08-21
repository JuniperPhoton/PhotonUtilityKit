//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/3/28.
//

import Foundation
import StoreKit
import OSLog

@available(iOS 15.0, macOS 12.0, *)
public struct ResolvedProduct {
    public let product: Product
    public let isActive: Bool
}

private let storeLogger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PhotonUtility",
                                 category: "store")

/// Provides easy access to the in-app purchase products.
///
/// You initialize this class by passing your identifiers, and the blocks to handle transcation changes.
///
/// It's an ``ObservableObject`` and it provides ``products`` and ``isLoading`` to be observed.
///
/// You use ``loadProducts()`` to load all products of your identifiers. Then you observe the changes of ``products`` to update your UI.
/// To restore App Store, use ``restore()``.
///
/// To purchase a product, use ``purchase(product:)``.
@MainActor
@available(iOS 15.0, macOS 12.0, *)
public class AppProduct: ObservableObject {
    private let observer: TransactionObserver
    
    /// Resolved products to be observed.
    @Published
    public var products: [ResolvedProduct] = []
    
    /// Observe if it's loading or not.
    /// This will be true on loading products or purchasing a product.
    ///
    /// You can observe this to disable buttons or show loading UI.
    @Published
    public var isLoading = false
    
    /// The identifiers you pass in the initializer.
    public let identifiers: [String]
    
    /// The onProductVerified block you pass in the initializer.
    public let onProductVerified: (String) -> Void
    
    /// The onProductRevocated block you pass in the initializer.
    public let onProductRevocated: (String) -> Void

    /// Initialize using your own identifiers and blocks to handle transcation events.
    /// - parameter identifiers: your product identifiers in an array
    /// - parameter onProductVerified: the block to be invoked when a product is verfied
    /// - parameter onProductRevocated: the block to be invoked when a product is revocated
    public init(identifiers: [String],
                onProductVerified: @escaping (String) -> Void,
                onProductRevocated: @escaping (String) -> Void) {
        self.identifiers = identifiers
        self.observer = TransactionObserver(identifiers: identifiers,
                                            onProductVerified: onProductVerified,
                                            onProductRevocated: onProductRevocated)
        self.onProductVerified = onProductVerified
        self.onProductRevocated = onProductRevocated
    }
    
    public func restore() async throws {
        withDefaultAnimation {
            self.isLoading = true
        }
        
        defer {
            withDefaultAnimation {
                self.isLoading = false
            }
        }
        
        storeLogger.log("start restore")
        
        do {
            try await AppStore.sync()
            await loadProducts()
            storeLogger.log("finish restore")
        } catch {
            storeLogger.log("error on restore \(error)")
            throw error
        }
    }
    
    public func loadProducts() async {
        withDefaultAnimation {
            self.isLoading = true
        }
        
        do {
            let appProducts = try await Product.products(for: identifiers)
            storeLogger.log("products are \(appProducts.count)")
            
            let products = await refreshProductTranscation(products: appProducts)
            withDefaultAnimation {
                self.products = products
                self.isLoading = false
            }
        } catch {
            storeLogger.log("error on getting products \(error)")
            withDefaultAnimation {
                self.isLoading = false
            }
        }
    }
    
    public func purchase(product: Product) async throws {
        do {
            storeLogger.log("begin purchase \(product.displayName)")
            
            withDefaultAnimation {
                isLoading = true
            }
            
            let result = try await product.purchase(options: [])
            switch result {
            case .success(let verification):
                //Check whether the transaction is verified. If it isn't,
                //this function rethrows the verification error.
                let transaction = checkVerified(verification)
                
                if let transaction = transaction {
                    storeLogger.log("purchase success")
                    await loadProducts()
                    await transaction.finish()
                } else {
                    storeLogger.log("purchase error, not verififed")
                }
            case .userCancelled:
                storeLogger.log("user cancelled")
            case .pending:
                storeLogger.log("purchase pending...")
            @unknown default:
                storeLogger.log("purchase unknown result...")
            }
            
            storeLogger.log("end purchase \(product.displayName)")
            
            withDefaultAnimation {
                self.isLoading = false
            }
        } catch {
            storeLogger.log("error on purchasing products \(error)")
            
            withDefaultAnimation {
                self.isLoading = false
            }
            
            throw error
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) -> T? {
        //Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit parses the JWS, but it fails verification.
            return nil
        case .verified(let safe):
            //The result is verified. Return the unwrapped value.
            return safe
        }
    }
    
    private func refreshProductTranscation(products: [Product]) async -> [ResolvedProduct] {
        var resolved: [ResolvedProduct] = []
        
        for product in products {
            if let transaction = await product.latestTransaction {
                let handledTranscation = observer.handle(updatedTransaction: transaction)
                resolved.append(ResolvedProduct(product: product, isActive: handledTranscation != nil))
            } else {
                storeLogger.error("no latestTransaction for \(product.id)")
                onProductRevocated(product.id)
                resolved.append(ResolvedProduct(product: product, isActive: false))
            }
        }
        
        return resolved
    }
}

@MainActor
@available(iOS 15.0, macOS 12.0, *)
fileprivate final class TransactionObserver {
    var updates: Task<Void, Never>? = nil
    let identifiers: [String]
    let onProductVerified: (String) -> Void
    let onProductRevocated: (String) -> Void
    
    init(identifiers: [String],
         onProductVerified: @escaping (String) -> Void,
         onProductRevocated: @escaping (String) -> Void) {
        self.identifiers = identifiers
        self.onProductVerified = onProductVerified
        self.onProductRevocated = onProductRevocated
        self.updates = newTransactionListenerTask()
    }
    
    deinit {
        // Cancel the update handling task when you deinitialize the class.
        updates?.cancel()
    }
    
    private func newTransactionListenerTask() -> Task<Void, Never> {
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                self.handle(updatedTransaction: verificationResult)
            }
        }
    }
    
    @discardableResult
    func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) -> Transaction? {
        guard case .verified(let transaction) = verificationResult else {
            // Ignore unverified transactions.
            storeLogger.log("handle but verificationResult is verified")
            return nil
        }
        
        if !identifiers.contains(transaction.productID) {
            return nil
        }
        
        storeLogger.log("handle updatedTransaction")
        
        if let _ = transaction.revocationDate {
            // Remove access to the product identified by transaction.productID.
            // Transaction.revocationReason provides details about
            // the revoked transaction.
            onProductRevocated(transaction.productID)
            return nil
        } else if let expirationDate = transaction.expirationDate,
                  expirationDate < Date() {
            // Do nothing, this subscription is expired.
            return nil
        } else if transaction.isUpgraded {
            // Do nothing, there is an active transaction
            // for a higher level of service.
            return nil
        } else {
            // Provide access to the product identified by
            // transaction.productID.
            let productId = transaction.productID
            storeLogger.log("handle updatedTransaction, provide access to \(productId)")
            onProductVerified(productId)
            return transaction
        }
    }
}
