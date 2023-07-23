//
//  ContentView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct ContentView: View {
    var body: some View {
        if #available(iOS 16.0, macOS 13.0, *), DeviceCompat.isMac() {
            EpicMainContentView()
        } else {
            DeprecatedMainContentView()
        }
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct EpicMainContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationSplitView {
            SidebarList(viewModel: viewModel)
        } detail: {
            EmptyView()
        }
    }
}

struct DeprecatedMainContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            SidebarList(viewModel: viewModel)
            
            EmptyView()
        }
    }
}

struct SidebarList: View {
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        List {
#if os(macOS)
            Text("PhotonUtilityKit Demo")
                .font(.title2.bold())
                .padding(.top)
#endif
            
            ForEach(viewModel.catalogyPages, id: \.id) { catagory in
                Section {
                    ForEach(catagory.pages, id: \.rawValue) { page in
                        NavigationLink {
                            page.viewBody
#if os(iOS)
                                .navigationBarTitleDisplayMode(.inline)
#endif
                        } label: {
                            Label(page.rawValue, systemImage: page.icon)
                        }
                    }
                } header: {
                    Text(catagory.cagatory.rawValue)
                }
            }
            
            Section {
                Link("Github", destination: URL(string: "https://github.com/JuniperPhoton/PhotonUtilityKit")!)
                Link("Twitter", destination: URL(string: "https://twitter.com/JuniperPhoton")!)
            } header: {
                Text("Links")
            }
        }
        .searchableCompact(text: $viewModel.searchText, placement: .sidebar)
        .onChange(of: viewModel.searchText) { newValue in
            viewModel.filterBySearchText()
        }
#if !os(tvOS)
        .listStyle(.sidebar)
#endif
        .navigationTitle("PhotonUtilityKit")
    }
}

struct EmptyView: View {
    var body: some View {
        VStack {
            Image("AboutIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text("Select a page from the sidebar to start")
        }
    }
}
