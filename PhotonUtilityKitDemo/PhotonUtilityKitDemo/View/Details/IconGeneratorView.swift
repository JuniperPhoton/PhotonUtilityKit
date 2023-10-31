//
//  IconGeneratorView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView
import UniformTypeIdentifiers
import PhotonMediaKit

class IconGeneratorViewModel: ObservableObject {
    @Published var imageURL: URL? = nil
    @Published var imageToDisplay: CGImage? = nil
    
    @MainActor
    func resolveImage(url: URL) async {
        imageURL = url
        
        guard let data = FileManager.default.contents(atPath: url.path) else {
            return
        }
        
        self.imageToDisplay = try? await ImageIO.shared.loadCGImage(data: data)
    }
    
    @MainActor
    func clear() {
        self.imageURL = nil
        self.imageToDisplay = nil
    }
    
    @MainActor
    func saveTo(url: URL) async -> Bool {
        return await url.grantAccessAsync { url in
            guard let imageURL = imageURL, let imageToDisplay = imageToDisplay else {
                return false
            }
            
            let nameWithoutExtension = imageURL.getNameWithoutExtension()
            let sizeToScale: [CGFloat] = [1024, 512, 256, 128, 64, 32, 16]
            
            let targetUTType = UTType.png
            
            var successCount = 0
            
            for size in sizeToScale {
                guard let scaledImage = await ImageIO.shared.scaleCGImage(image: imageToDisplay, width: size, height: size) else {
                    continue
                }
                let fileURL = url.appendingPathComponent("\(nameWithoutExtension)-\(Int(size))", conformingTo: targetUTType)
                if !FileManager.default.createFile(atPath: fileURL.pathExtension, contents: nil) {
                    continue
                }
                
                do {
                    let _ = try await ImageIO.shared.saveToFile(file: fileURL, cgImage: scaledImage, utType: targetUTType)
                    successCount += 1
                } catch {
                    // ignored
                }
            }
            
            return successCount == sizeToScale.count
        }
    }
}

struct IconGeneratorView: View {
    @StateObject private var appToast = AppToast()
    @StateObject private var viewModel = IconGeneratorViewModel()
    
    @State private var showImportPicker = false
    @State private var showExportPicker = false
    @State private var dropping = false
    
    var body: some View {
#if os(macOS)
        ZStack {
            VStack {
                if let image = viewModel.imageToDisplay {
                    Image(image, scale: 1.0, label: Text("Icon image"))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    if #available(macOS 13.0, *) {
                        Text("""
                            Drop file here to begin.
                            
                            You should import an image with at least 1024x1024 resolutions to get better outputs.
                            
                            This will scale the image down to this size and save: 1024, 512, 256, 128, 64, 32 and 16.
                            """)
                        .matchParent()
                        .background {
                            if dropping {
                                Rectangle().fill(Color.accentColor.opacity(0.1))
                            }
                        }
                        .onDrop(of: [.url], isTargeted: $dropping) { providers in
                            guard let provider = providers.first else {
                                return true
                            }
                            
                            Task {
                                let url = await provider.loadAsUrl()
                                if let url = url {
                                    print("loadFileRepresentation \(url)")
                                    await viewModel.resolveImage(url: url)
                                } else {
                                    print("error on loadFileRepresentation")
                                }
                            }
                            return true
                        }
                    } else {
                        Text("Select file to begin")
                    }
                }
            }
            
            ToastView(appToast: appToast)
        }
        .environmentObject(appToast)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Text("Scale and save").asButton {
                    showExportPicker.toggle()
                }
                .fileImporter(isPresented: $showExportPicker, allowedContentTypes: [.folder]) { result in
                    guard let url = try? result.get() else {
                        return
                    }
                    
                    Task {
                        if await viewModel.saveTo(url: url) {
                            appToast(.constant("Success"))
                        } else {
                            appToast(.constant("Failed"))
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("Pick from file").asButton {
                    showImportPicker.toggle()
                }
                .fileImporter(isPresented: $showImportPicker, allowedContentTypes: [.jpeg, .png]) { result in
                    guard let url = try? result.get() else {
                        return
                    }
                    
                    Task {
                        await viewModel.resolveImage(url: url)
                    }
                }
                
                Text("Clear").asButton {
                    viewModel.clear()
                }
            }
            
            ToolbarItem(placement: .navigation) {
                Text("Clear").asButton {
                    viewModel.clear()
                }
            }
        }
#else
        Text("Not supported")
#endif
    }
}
