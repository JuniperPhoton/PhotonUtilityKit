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
    @State private var colorScheme: ColorScheme = .light
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            List {
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
            }
            .searchableCompact(text: $viewModel.searchText, placement: .sidebar)
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.refresh()
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Image(systemName: colorScheme == .light ? "moon" : "sun.max").asButton {
                        colorScheme = colorScheme == .light ? .dark : .light
                    }
                }
            }
            .navigationTitle("PhotonUtilityKit")
            
            VStack {
                Image(systemName: "text.book.closed")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                
                Text("Select a page in the sidebar to start")
            }
        }
        .preferredColorScheme(colorScheme)
    }
}
