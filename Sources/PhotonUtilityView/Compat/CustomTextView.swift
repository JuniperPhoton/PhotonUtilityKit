//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/4/28.
//

import SwiftUI

#if canImport(AppKit)
struct CustomInternalTextView: View {
    let text: String
    
    @State private var resultImage: CGImage? = nil
    @State private var parentWidth: CGFloat = 0.0
    
    var body: some View {
        Group {
            if let image = resultImage {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .scaledToFit()
            }
            
            Text(text)
        }.matchParent().listenWidthChanged(onWidthChanged: { width in
            self.parentWidth = width
            self.drawCGImage()
        }).onChange(of: text) { newValue in
            self.drawCGImage()
        }
    }
    
    private func drawCGImage() {
        if parentWidth == 0.0 || text.isEmpty {
            resultImage = nil
            return
        }
        
        let font = CTFontCreateWithName("Helvetica" as CFString, 25, nil)
        let factor = NSScreen.main?.backingScaleFactor ?? 1.0
        resultImage = createImageWithText(text: text, font: font,
                                          textColor: .black, imageSize: .init(width: parentWidth * factor, height: .infinity))
    }
    
    private func createImageWithText(text: String, font: CTFont, textColor: CGColor, imageSize: CGSize) -> CGImage? {
        let string = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)!
        CFAttributedStringReplaceString(string, CFRangeMake(0, 0), text as CFString)
        CFAttributedStringSetAttribute(string, CFRangeMake(0, text.count), kCTFontAttributeName, font)
        CFAttributedStringSetAttribute(string, CFRangeMake(0, text.count), kCTForegroundColorAttributeName, textColor)
        
        let framesetter = CTFramesetterCreateWithAttributedString(string)
        
        let widthConstraint = CGSize(width: imageSize.width, height: CGFloat.greatestFiniteMagnitude)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                                         CFRange(location: 0,
                                                                                 length: text.count),
                                                                         nil, widthConstraint, nil)
        
        let size = CGSize(width: imageSize.width, height: suggestedSize.height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        
        let path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.count), path, nil)
        
        context.clear(CGRect(origin: .zero, size: size))
        context.textMatrix = CGAffineTransform.identity
        
        CTFrameDraw(frame, context)
        
        return context.makeImage()
    }
}

/// A custom text view. It uses CoreGraphics & CoreText to render text.
/// This is under the experiment. Please do not use it in production.
public struct CustomTextView: View {
    let text: String
    
    @State private var resultImage: CGImage? = nil
    @State private var parentWidth: CGFloat = 0.0
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        ScrollView {
            CustomInternalTextView(text: text)
        }.matchWidth()
    }
}
#endif
