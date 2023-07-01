//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/1.
//

import SwiftUI

#if canImport(UIKit) && !targetEnvironment(macCatalyst)
import UIKit

public struct UIPageView<T: Equatable, V: View>: UIViewControllerRepresentable {
    let selection: Binding<Int>
    let pageObjects: [T]
    let idKeyPath: KeyPath<T, String>
    let contentView: (T) -> V
    
    public init(selection: Binding<Int>,
                pageObjects: [T],
                idKeyPath: KeyPath<T, String>,
                contentView: @escaping (T) -> V) {
        self.selection = selection
        self.pageObjects = pageObjects
        self.idKeyPath = idKeyPath
        self.contentView = contentView
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = CustomUIPageViewController<T, V>(transitionStyle: .scroll,
                                                          navigationOrientation: .horizontal,
                                                          options: nil)
        controller.setup(selection: selection, pageObjects: pageObjects, pageToView: contentView)
        controller.onSelectionChanged = { index in
            self.selection.wrappedValue = index
        }
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        print("dwccc updateUIViewController \(selection.wrappedValue)")
        if let controller = uiViewController as? CustomUIPageViewController<T, V> {
            controller.setup(selection: selection, pageObjects: pageObjects, pageToView: contentView)
            controller.updatePage(animated: true)
        }
    }
}

public class CustomUIPageViewController<T: Equatable, V: View>: UIPageViewController, UIPageViewControllerDelegate,
                                                                UIPageViewControllerDataSource {
    private var selection: Binding<Int>? = nil
    private var pageObjects: [T]? = nil
    private var pageToView: ((T) -> V)? = nil
    
    private var currentPage: T? = nil
    private var currentViewController: UIViewController? = nil
    
    var onSelectionChanged: ((Int) -> Void)? = nil
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        self.dataSource = self
        self.delegate = self
        self.updatePage(animated: false)
    }
    
    func setup(selection: Binding<Int>, pageObjects: [T], pageToView: @escaping (T) -> V) {
        self.selection = selection
        self.pageObjects = pageObjects
        self.pageToView = pageToView
    }
    
    func updatePage(animated: Bool) {
        if let selection = selection,
           let pageObjects = pageObjects,
           let pageToView = pageToView {
            print("dwccc udpate page \(selection.wrappedValue)")
            
            let nextIndex = selection.wrappedValue
            let nextPage = pageObjects[nextIndex]
            
            if currentPage == nextPage {
                return
            }
            
            let nextView = pageToView(nextPage)
            let controller = PageDetailViewController<T>(page: nextPage, view: AnyView(nextView))
            var direction: UIPageViewController.NavigationDirection = .forward
            
            if let currentPage = currentPage,
               let currentIndex = pageObjects.firstIndex(of: currentPage) {
                if currentIndex < nextIndex {
                    direction = .reverse
                }
            }
            
            currentPage = nextPage
            currentViewController = controller
            
            setViewControllers([controller], direction: direction, animated: animated)
        }
    }
    
    func getPage(before: T) -> T? {
        if let pageObjects = pageObjects {
            let index = pageObjects.firstIndex { page in
                page == before
            }
            if index == nil || index == 0 {
                return nil
            }
            return pageObjects[index! - 1]
        } else {
            return nil
        }
    }
    
    func getPage(after: T) -> T? {
        if let pageObjects = pageObjects {
            let index = pageObjects.firstIndex { page in
                page == after
            }
            if index == nil || index == pageObjects.count - 1 {
                return nil
            }
            return pageObjects[index! + 1]
        } else {
            return nil
        }
    }
    
    private func invokePageChanged() {
        if let page = currentPage, let index = pageObjects?.firstIndex(of: page) {
            self.onSelectionChanged?(index)
        }
    }
    
    // MARK: UIPageViewControllerDelegate impl
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageObjects?.count ?? 0
    }
    
    private var pendingTransitionToViewController: PageDetailViewController<T>? = nil
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let next = pendingViewControllers.first as? PageDetailViewController<T> else {
            return
        }
        self.pendingTransitionToViewController = next
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        if finished, let vc = pendingTransitionToViewController {
            self.currentPage = vc.page
            self.currentViewController = vc
            self.pendingTransitionToViewController = nil
            self.invokePageChanged()
        }
    }
    
    // MARK: UIPageViewControllerDataSource impl
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let detailViewController = viewController as? PageDetailViewController<T> else {
            return nil
        }
        let page = detailViewController.page
        guard let beforePage = getPage(before: page) else {
            return nil
        }
        guard let pageToView = pageToView else {
            return nil
        }
        print("dwccc get before page of \(beforePage)")
        return PageDetailViewController<T>(page: beforePage, view: AnyView(pageToView(beforePage)))
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let detailViewController = viewController as? PageDetailViewController<T> else {
            return nil
        }
        let page = detailViewController.page
        guard let nextPage = getPage(after: page) else {
            return nil
        }
        guard let pageToView = pageToView else {
            return nil
        }
        print("dwccc get after page of \(nextPage)")
        return PageDetailViewController<T>(page: nextPage, view: AnyView(pageToView(nextPage)))
    }
}

class PageDetailViewController<T: Equatable>: UIHostingController<AnyView> {
    let page: T
    
    init(page: T, view: AnyView) {
        self.page = page
        super.init(rootView: view)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
}
#endif
