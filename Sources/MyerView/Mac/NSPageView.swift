//
//  NSPageView.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/17.
//

import SwiftUI
import MyerLib

#if canImport(AppKit)
import AppKit

/// A NSViewControllerRepresentable for showing NSPageController.
/// Use ``init(selection:pageObjects:idKeyPath:contentView:)`` to initialize a view and add it to a SwiftUI view hierachy.
public struct NSPageView<T, V>: NSViewControllerRepresentable where V: View {
    let selection: Binding<Int>
    let pageObjects: [T]
    let idKeyPath: KeyPath<T, String>
    let contentView: (T) -> V
    
    /// Construct a ``NSPageView``.
    /// - parameter selection: a binding to the selected index, which should in range of ``pageObjects``
    /// - parameter pageObjects: provides data source
    /// - parameter idKeyPath: key path to access the id of ``T``
    /// - parameter contentView: given a ``T`` from ``pageObjects``, return a view to be displayed
    public init(selection: Binding<Int>,
                pageObjects: [T],
                idKeyPath: KeyPath<T, String>,
                contentView: @escaping (T) -> V) {
        self.selection = selection
        self.pageObjects = pageObjects
        self.idKeyPath = idKeyPath
        self.contentView = contentView
    }
    
    public func makeNSViewController(context: Context) -> some NSViewController {
        let controller = NSPageViewContainerController()
        controller.pageObjects = pageObjects
        controller.idFromObject = { object in
            return (object as! T)[keyPath: idKeyPath]
        }
        controller.objectToView = { object in
            return AnyView(contentView(object as! T))
        }
        controller.idToObject = { id in
            return pageObjects.first { page in
                let pageId = page[keyPath: idKeyPath]
                return pageId == id
            }!
        }
        controller.onSelectedIndexChanged = { index in
            withTransaction(selection.transaction) {
                selection.wrappedValue = index
            }
        }
        controller.transitionStyle = .horizontalStrip
        return controller
    }
    
    public func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        guard let pageViewController = nsViewController as? NSPageViewContainerController else {
            return
        }
        if pageViewController.selectedIndex != selection.wrappedValue {
            pageViewController.updateSelectedIndex(selection.wrappedValue)
        }
    }
}

class NSPageViewContainerController: NSPageController, NSPageControllerDelegate, NSWindowDelegate {
    var pageObjects: [Any] = []
    
    var idFromObject: ((Any) -> String)? = nil
    var idToObject: ((String) -> Any)? = nil
    var objectToView: ((Any) -> AnyView)? = nil
    
    var onSelectedIndexChanged: ((Int) -> Void)? = nil
    
    override var selectedIndex: Int {
        didSet {
            let index = selectedIndex
            DispatchQueue.main.async {
                self.onSelectedIndexChanged?(index)
            }
        }
    }
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.arrangedObjects = pageObjects
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        self.view.subviews.forEach { v in
            v.frame = self.view.bounds
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.delegate = self
    }
    
    func updateSelectedIndex(_ index: Int) {
        NSAnimationContext.runAnimationGroup { context in
            self.animator().selectedIndex = index
        } completionHandler: {
            self.completeTransition()
        }
    }
    
    func pageController(_ pageController: NSPageController,
                        identifierFor object: Any) -> NSPageController.ObjectIdentifier {
        return idFromObject?(object) ?? ""
    }
    
    func pageController(_ pageController: NSPageController,
                        viewControllerForIdentifier identifier: NSPageController.ObjectIdentifier) -> NSViewController {
        let object = idToObject!(identifier)
        let controller = NSPageViewContentController()
        controller.content = objectToView
        controller.object = object
        return controller
    }
    
    func windowDidResize(_ notification: Notification) {
        self.completeTransition()
    }
    
    func windowDidExitFullScreen(_ notification: Notification) {
        self.completeTransition()
    }
    
    func windowDidEnterFullScreen(_ notification: Notification) {
        self.completeTransition()
    }
}

class NSPageViewContentController: NSViewController {
    var content: ((Any) -> AnyView)? = nil
    var object: Any? = nil
    
    private var hostingController: NSHostingController<AnyView>? = nil
    
    override func loadView() {
        self.view = NSView()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        hostingController?.view.frame = self.view.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let object = object, let content = content else {
            return
        }
        let view = content(object)
        self.hostingController = NSHostingController(rootView: view)
        self.view.addSubview(self.hostingController!.view)
    }
}
#endif
