//
//  AppPopover.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/8/8.
//

import SwiftUI

public extension View {
    /// Shows a view inside a popover, anchoring to the current view.
    /// This is availabe on iOS, iPadOS and macOS.
    func popoverCompat<Content: View>(isPresented: Binding<Bool>,
                                      @ViewBuilder content: @escaping () -> Content) -> some View {
#if os(macOS)
        self.disabled(isPresented.wrappedValue)
            .popover(isPresented: isPresented, content: content)
#elseif os(iOS)
        // For iOS 16.4+, a API called presentationCompactAdaptation(_:) can be used to adjust
        // the presentation style for compact horizontal class size.
        // However if we display a long text insider the popover its height can't be calculated in the right way.
        // So we stick to the compat version of popover.
        // Sigh...
        self.disabled(isPresented.wrappedValue)
            .modifier(AlwaysPopoverModifier(isPresented: isPresented, contentBlock: content))
#else
        self
#endif
    }
}

#if os(iOS)
private class ContentViewController<V: View>: UIHostingController<V>, UIPopoverPresentationControllerDelegate {
    var isPresented: Binding<Bool>
    
    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.isPresented.wrappedValue = false
    }
}

private struct AlwaysPopoverModifier<PopoverContent: View>: ViewModifier {
    // Workaround for the missing `@StateObject` in iOS 13.
    private struct Store {
        var anchorView = UIView()
    }
    
    @State private var store = Store()
    
    let isPresented: Binding<Bool>
    let contentBlock: () -> PopoverContent
    
    func body(content: Content) -> some View {
        if isPresented.wrappedValue {
            presentPopover()
        }

        return content
            .background(InternalAnchorView(uiView: store.anchorView))
    }
    
    private func presentPopover() {
        let contentController = ContentViewController(rootView: contentBlock(), isPresented: isPresented)
        contentController.modalPresentationStyle = .popover
        contentController.title = "PopoverContentViewController"

        let view = store.anchorView
        guard let popover = contentController.popoverPresentationController else { return }
        popover.sourceView = view
        popover.sourceRect = view.bounds
        popover.delegate = contentController

        guard let sourceVC = view.closestVC() else { return }
        if let presentedVC = sourceVC.presentedViewController {
            presentedVC.dismiss(animated: true) {
                sourceVC.present(contentController, animated: true)
            }
        } else {
            sourceVC.present(contentController, animated: true)
        }
    }
}

private extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            }
            responder = responder?.next
        }
        return nil
    }
}

private struct InternalAnchorView: UIViewRepresentable {
    typealias UIViewType = UIView
    let uiView: UIView

    func makeUIView(context: Self.Context) -> Self.UIViewType {
        uiView
    }

    func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
}
#endif
