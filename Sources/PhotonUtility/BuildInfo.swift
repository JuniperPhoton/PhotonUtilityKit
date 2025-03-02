//
//  BuildInfo.swift
//  PhotonCamSharedUtils
//
//  Created by JuniperPhoton on 2024/11/6.
//
import Foundation

public class AppBuildInfo {
    public static let isTestFlightBuild: Bool = {
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            return false // No receipt means it's not a TestFlight build
        }
        
        // The receipt URL for TestFlight builds typically has "sandbox" in its path
        return appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
    }()
    
    public static let shortVersion: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }()
    
    public static let buildVersion: String = {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }()
    
    public static let isDebug: Bool = {
#if DEBUG
        return true
#else
        return false
#endif
    }()
    
    private init() {
        // empty
    }
}
