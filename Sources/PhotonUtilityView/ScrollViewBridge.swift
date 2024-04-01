//
//  SwiftUIView.swift
//
//
//  Created by Photon Juniper on 2024/3/24.
//

import SwiftUI

#if os(iOS)
/// Bridge to the ``UIScrollView`` from UIKit for SwiftUI to use.
///
/// Example code:
///
/// ```Swift
/// if let image = viewModel.inputImage {
///     GeometryReader { proxy in
///         ScrollViewBridge(
///             actualContentAspectRatio: image.extent.size,
///             scrollViewSize: proxy.size
///         ) {
///             MetalView(renderer: viewModel.renderer, enableSetNeedsDisplay: true)
///                 .frame(width: proxy.size.width, height: proxy.size.height)
///         }
///     }.id(viewModel.inputImage)
/// }
/// ```
/// If the aspect ratio of the content view will change, you should invalide this view and force it to reconstruct.
/// For example, you can use ``id(_:)`` to invalide this view.
public struct ScrollViewBridge<ContentView: View>: UIViewRepresentable {
    let contentView: () -> ContentView
    
    let maxScale: CGFloat
    let controller: ScrollViewBridgeController?
    let actualContentAspectRatio: CGSize
    let scrollViewSize: CGSize
    
    /// Initialize ``ScrollViewBridge``.
    /// - parameter controller: The optional instance of ``ScrollViewBridgeController``.
    /// If the size of ScrollView can be changed, use the method in ``ScrollViewBridgeController`` to notify UI changed.
    ///
    /// - parameter scrollViewSize: The size of this ``UIScrollView``. You should wrap this inside a ``GeometryReader`` to get the size of it.
    /// The content view's frame should also be set to the size from ``GeometryReader``.
    ///
    /// - parameter actualContentAspectRatio: The aspect ratio of the content view. Currently the content view will be scaled to fit this scroll view.
    /// - parameter contentView: Block to get the content view.
    public init(
        maxScale: CGFloat = 3.0,
        controller: ScrollViewBridgeController? = nil,
        actualContentAspectRatio: CGSize,
        scrollViewSize: CGSize,
        contentView: @escaping () -> ContentView
    ) {
        self.maxScale = maxScale
        self.contentView = contentView
        self.controller = controller
        self.scrollViewSize = scrollViewSize
        self.actualContentAspectRatio = actualContentAspectRatio
    }
    
    public func makeCoordinator() -> ScrollViewBridgeCoordinator {
        return ScrollViewBridgeCoordinator()
    }
    
    public func makeUIView(context: Context) -> some UIView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        
        var frame = CGRect(x: 0, y: 0, width: scrollViewSize.width, height: scrollViewSize.height)
        frame = frame.largestAspectFitRect(of: actualContentAspectRatio)
        
        let hostingController = UIHostingController(rootView: contentView())
        hostingController.view.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        let diffContentX = scrollViewSize.width - frame.width
        let diffContentY = scrollViewSize.height - frame.height
        
        scrollView.addSubview(hostingController.view)
        scrollView.contentInset = UIEdgeInsets(
            top: diffContentY / 2,
            left: diffContentX / 2,
            bottom: diffContentY / 2,
            right: diffContentX / 2
        )
        scrollView.maximumZoomScale = maxScale
        scrollView.minimumZoomScale = 1
        scrollView.zoomScale = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        // We should not reference properties from this UIViewRepresentable struct.
        // Although it seems OK but refering properties will cause memory leak.
        // For example, if we refer the maxScale from the ScrollViewBridge,
        // the ScrollViewBridgeController will leak.
        controller?.onRequestUpdateContentSize = { [weak scrollView] scrollViewSize in
            guard let scrollView = scrollView else { return }
            context.coordinator.centerViewOnNewSize(scrollView, scrollViewSize: scrollViewSize)
        }
        controller?.onRequestZoom = { [weak scrollView] point, scale in
            guard let scrollView = scrollView else { return }
            context.coordinator.zoom(scrollView, to: point, scaleFactor: scale)
        }
        
        context.coordinator.onZoomed = { [weak controller] scale in
            controller?.zoomScaleFactor = scale
        }
        
        return scrollView
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        // ignored
        guard let _ = uiView as? UIScrollView else {
            return
        }
        
        context.coordinator.actualContentAspectRatio = actualContentAspectRatio
        context.coordinator.maxScale = maxScale
    }
}

public class ScrollViewBridgeCoordinator: NSObject, UIScrollViewDelegate {
    var actualContentAspectRatio: CGSize = .zero
    var maxScale: CGFloat = 3.0
    var onZoomed: ((CGFloat) -> Void)? = nil
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // To get better snap-to-edge experience,
        // we adjust the scrollView's content insets each time we scroll.
        centerView(scrollView)
        onZoomed?(scrollView.zoomScale)
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // To get better snap-to-edge experience,
        // we adjust the scrollView's content insets each time we scroll.
        centerView(scrollView)
        onZoomed?(scale)
    }
    
    fileprivate func zoom(_ scrollView: UIScrollView, to point: CGPoint, scaleFactor: CGFloat) {
        let bounds = scrollView.bounds
        
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        
        let targetScale = minScale + (maxScale - minScale) * (scaleFactor - 1)
        
        let targetWidth = bounds.width / targetScale
        let targetHeight = bounds.height / targetScale
        
        let targetRect = CGRect(
            x: point.x * bounds.width,
            y: point.y * bounds.height,
            width: targetWidth,
            height: targetHeight
        ).offsetBy(dx: -targetWidth / 2, dy: -targetHeight / 2)
        
        scrollView.zoom(to: targetRect, animated: true)
    }
    
    fileprivate func centerViewOnNewSize(_ scrollView: UIScrollView, scrollViewSize: CGSize) {
        guard let contentView = scrollView.subviews.first else {
            return
        }
        
        let contentViewSize = contentView.bounds.size
        
        let contentSize = CGRect(x: 0, y: 0, width: contentViewSize.width, height: contentViewSize.height)
            .largestAspectFitRect(of: actualContentAspectRatio)
        
        let widthScale = scrollViewSize.width / contentSize.width
        let heightScale = scrollViewSize.height / contentSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale + (minScale < 1 ? (1 - minScale) : 0)
        
        let contentWidth = contentSize.width * minScale
        let contentHeight = contentSize.height * minScale
        let offsetX = (scrollViewSize.width - contentWidth) / 2.0 - contentSize.minX * minScale
        let offsetY = (scrollViewSize.height - contentHeight) / 2.0 - contentSize.minY * minScale
        
        let insets = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            scrollView.zoomScale = minScale
            scrollView.contentInset = insets
        }
    }
    
    private func centerView(_ scrollView: UIScrollView) {
        guard let contentView = scrollView.subviews.first else {
            return
        }
        
        let boundsSize = scrollView.bounds.size
        
        if scrollView.zoomScale <= scrollView.minimumZoomScale {
            var frame = CGRect(x: 0, y: 0, width: boundsSize.width, height: boundsSize.height)
            frame = frame.largestAspectFitRect(of: actualContentAspectRatio)
            
            let xd = -(frame.width - boundsSize.width) / 2
            let yd = -(frame.height - boundsSize.height) / 2
            
            UIView.animate(withDuration: 0.2) {
                scrollView.contentInset = UIEdgeInsets(top: yd, left: xd, bottom: yd, right: xd)
            }
            return
        }
        
        // The contentView's frame may larger than the scrollView's frame. Since it's zoomed in.
        let contentsFrame = contentView.frame
        let contentsBodyFrame = contentsFrame.largestAspectFitRect(of: actualContentAspectRatio)
        
        let diffContentX = contentsFrame.width - contentsBodyFrame.width
        let diffContentY = contentsFrame.height - contentsBodyFrame.height
        
        if contentsBodyFrame.height < boundsSize.height || contentsBodyFrame.width < boundsSize.width {
            let diffX = diffContentX / 2 - max(0, boundsSize.width - contentsBodyFrame.width) / 2
            let diffY = diffContentY / 2 - max(0, boundsSize.height - contentsBodyFrame.height) / 2
            
            UIView.animate(withDuration: 0.2) {
                scrollView.contentInset = UIEdgeInsets(
                    top: -diffY,
                    left: -diffX,
                    bottom: -diffY,
                    right: -diffX
                )
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                scrollView.contentInset = UIEdgeInsets(
                    top: -diffContentY / 2,
                    left: -diffContentX / 2,
                    bottom: -diffContentY / 2,
                    right: -diffContentX / 2
                )
            }
        }
    }
}

public protocol ScrollViewBridgeControllerProtocol {
    func requestUpdateContentSize(scrollViewSize: CGSize)
    func requestZoom(to point: CGPoint, scaleFactor: CGFloat)
}

/// A controller as a coordinator.
/// You can receive zoom scale factor changes via ``zoomScaleFactor``.
///
/// To notify the inner view to get update when the size of ScrollView changes, call ``requestUpdateContentSize``.
/// To zoom manually, call ``requestZoom(to:scaleFactor:)``.
public class ScrollViewBridgeController: ObservableObject, ScrollViewBridgeControllerProtocol {
    var onRequestUpdateContentSize: ((CGSize) -> Void)? = nil
    var onRequestZoom: ((CGPoint, CGFloat) -> Void)? = nil
    
    private var delayItem: DispatchWorkItem? = nil
    
    @Published public fileprivate(set) var zoomScaleFactor: CGFloat = 1.0
    
    public init() {
        // ignored
    }
    
    /// Call this method to update content size when the size of ScrollView changed.
    public func requestUpdateContentSize(scrollViewSize: CGSize) {
        self.delayItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.onRequestUpdateContentSize?(scrollViewSize)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: item)
        self.delayItem = item
    }
    
    /// Request the scroll view to scroll to the specified point with a scale factor.
    ///
    /// - parameter point: The point to be visible. Must be normalized to 0...1 and in the coordinate space of ScrollView.
    /// That's, if the content view is smaller than the scrollView, then you need to calculate the offset.
    ///
    /// - parameter scaleFactor: The scale factor to be applied. Must be 1...maxScale.
    public func requestZoom(to point: CGPoint, scaleFactor: CGFloat) {
        self.onRequestZoom?(point, scaleFactor)
    }
    
    /// Request the scroll view to reset zoom to min scale.
    public func resetZoom() {
        requestZoom(to: CGPoint(x: 0.5, y: 0.5), scaleFactor: 1.0)
    }
}
#endif
