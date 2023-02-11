//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2022/12/24.
//

import SwiftUI

protocol MyerSeriesApp {
    var title: String { get }
    var description: String { get }
    var icon: String { get }
    var themeColor: Color { get }
    var backgroundColor: Color { get }
    var storeLink: URL { get }
}

struct MyerListApp: MyerSeriesApp {
    var title: String {
        return "MyerList"
    }
    
    var description: String {
        return "MyerListDesc"
    }
    
    var icon: String {
        return "myerlist"
    }
    
    var themeColor: Color {
        return Color(hex: 0x0060ff)
    }
    
    var backgroundColor: Color {
        return Color(hex: 0xfbfcff)
    }
    
    var storeLink: URL {
        return URL(string: "https://apps.apple.com/us/app/myerlist/id1659589940")!
    }
}

struct MyerTidyApp: MyerSeriesApp {
    var title: String {
        return "MyerTidy"
    }
    
    var description: String {
        return "MyerTidyDesc"
    }
    
    var icon: String {
        return "myertidy"
    }
    
    var themeColor: Color {
        return Color(hex: 0x894F16)
    }
    
    var backgroundColor: Color {
        return Color(hex: 0xfdfcfb)
    }
    
    var storeLink: URL {
        return URL(string: "https://apps.apple.com/us/app/myertidy/id1609860733")!
    }
}

struct MyerSplashApp: MyerSeriesApp {
    var title: String {
        return "MyerSplash"
    }
    
    var description: String {
        return "MyerSplashDesc"
    }
    
    var icon: String {
        return "myersplash"
    }
    
    var themeColor: Color {
        return Color(hex: 0x2A8F9A)
    }
    
    var backgroundColor: Color {
        return Color(hex: 0xfcfdfd)
    }
    
    var storeLink: URL {
        return URL(string: "https://apps.apple.com/us/app/myersplash/id1486017120")!
    }
}

struct MyerSplash2App: MyerSeriesApp {
    var title: String {
        return "MyerSplash 2"
    }
    
    var description: String {
        return "MyerSplash2Desc"
    }
    
    var icon: String {
        return "myersplash2"
    }
    
    var themeColor: Color {
        return Color(hex: 0xFFFFFF)
    }
    
    var backgroundColor: Color {
        return Color(hex: 0x000000)
    }
    
    var storeLink: URL {
        return URL(string: "https://apps.apple.com/us/app/myersplash-2/id1670114025")!
    }
}

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 16.0, *)
public struct MyerSeriesAppsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let apps: [any MyerSeriesApp] = [
        MyerSplashApp(), MyerSplash2App(), MyerTidyApp(), MyerListApp()
    ]
    
    private let fontName = "DIN Condensed"

    var showView: Binding<Bool>
    
    public init(showView: Binding<Bool>) {
        self.showView = showView
    }
    
    public var body: some View {
        VStack {
            VStack {
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .padding(20)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showView.wrappedValue.toggle()
                    }
            }.matchParent(axis: .width, alignment: .topTrailing)
            
            VStack(alignment: .leading) {
                Text(LocalizedStringKey("MyerSeries apps"), bundle: .module)
                    .font(.custom(fontName, size: 50, relativeTo: .title).bold())
                
                Text("by JuniperPhoton")
                    .padding(0)
                    .font(.custom(fontName, size: 20, relativeTo: .body))
            }.matchParent(axis: .width, alignment: .leading).frame(maxWidth: 400)
            
            Spacer().frame(height: 20)

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 4)
                    ForEach(apps, id: \.title) { app in
                        AppView(app: app).padding(.horizontal)
                        if apps.firstIndex(where: { $0.title == app.title}) != apps.count - 1 {
                            Divider()
                                .frame(maxWidth: 400)
                        }
                    }
                }
                Spacer().frame(height: 20)
            }
            
        }.padding(0)
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 600)
        #endif
    }
}

struct AppView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let app: MyerSeriesApp
    
    var body: some View {
        Button {
            openURL(app.storeLink)
        } label: {
            HStack {
                Image(packageResource: app.icon, ofType: "png")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(app.title)
                        .font(.title2.bold())
                    
                    Text(LocalizedStringKey(app.description), bundle: .module)
                        .lineLimit(10)
                        .opacity(0.8)
                }
            }
            .frame(maxWidth: 400, maxHeight: .infinity, alignment: .leading)
//            .padding(12)
//            .background(RoundedRectangle(cornerRadius: 12).fill(colorScheme == .light ? .white : Color(hex: 0x2d2d2e))
//                .addShadow(x: 0, y: 0))
        }.buttonStyle(.plain)
    }
}

extension Image {
    init(packageResource name: String, ofType type: String) {
#if canImport(UIKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
#elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
#else
        self.init(name)
#endif
    }
}
