//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2022/12/24.
//

import SwiftUI

struct App {
    let title: String
    let description: String
    let icon: String
    let themeColor: Color
    let backgroundColor: Color
    let storeLink: URL
}

let photonAIApp = App(title: "Photon AI Translator",
                      description: "PhotonAIDesc",
                      icon: "photonai",
                      themeColor: Color(hex: 0xae481d),
                      backgroundColor: Color(hex: 0xfefbfa),
                      storeLink: URL(string: "https://apps.apple.com/us/app/photon-ai-translator/id6446066013")!)
let myerListApp = App(title: "MyerList",
                      description: "MyerListDesc",
                      icon: "myerlist",
                      themeColor: Color(hex: 0x0060ff),
                      backgroundColor: Color(hex: 0xfbfcff), storeLink: URL(string: "https://apps.apple.com/us/app/myerlist/id1659589940")!)

let myerTidyApp = App(title: "MyerTidy",
                      description: "MyerTidyDesc",
                      icon: "myertidy",
                      themeColor: Color(hex: 0x894F16),
                      backgroundColor: Color(hex: 0xfdfcfb),
                      storeLink: URL(string: "https://apps.apple.com/us/app/myertidy/id1609860733")!)

let myerSplashApp = App(title: "MyerSplash",
                        description: "MyerSplashDesc",
                        icon: "myersplash",
                        themeColor: Color(hex: 0x2A8F9A),
                        backgroundColor: Color(hex: 0xfcfdfd),
                        storeLink: URL(string: "https://apps.apple.com/us/app/myersplash/id1486017120")!)

let myerSplash2App = App(title: "MyerSplash 2",
                         description: "MyerSplash2Desc",
                         icon: "myersplash2",
                         themeColor: Color(hex: 0xFFFFFF),
                         backgroundColor: Color(hex: 0x000000),
                         storeLink: URL(string: "https://apps.apple.com/us/app/myersplash-2/id1670114025")!)

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 16.0, *)
public struct AllAppsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let apps: [App] = [
        photonAIApp, myerSplash2App, myerListApp, myerTidyApp, myerSplashApp
    ]
    
    private let fontName = "DIN Condensed"
    private let maxWidth: CGFloat = 360

    var showView: Binding<Bool>
    
    public init(showView: Binding<Bool>) {
        self.showView = showView
    }
    
    public var body: some View {
        VStack {
            Spacer().frame(height: 20)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizedStringKey("All apps"), bundle: .module)
                        .font(.largeTitle.bold())
                    
                    Text("by JuniperPhoton")
                        .padding(0)
                        .font(.custom(fontName, size: 16, relativeTo: .body))
                }
                
                Spacer()
                
                Image(systemName: "xmark")
                    .renderingMode(.template)
                    .padding(16)
                    .contentShape(Rectangle())
                    .asPlainButton {
                        showView.wrappedValue.toggle()
                    }
            }.frame(maxWidth: maxWidth)
                        
            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 4)
                    ForEach(apps, id: \.title) { app in
                        AppView(app: app)
                        if apps.firstIndex(where: { $0.title == app.title}) != apps.count - 1 {
                            Divider()
                                .frame(maxWidth: maxWidth)
                        }
                    }
                }
                Spacer().frame(height: 20)
            }
        }
        .padding()
        #if os(macOS)
        .frame(minWidth: maxWidth, minHeight: 600)
        #endif
    }
}

struct AppView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) var colorScheme
    
    let app: App
    
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
            .contentShape(Rectangle())
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
