//
//  RootView.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI

struct RootView: View {
    @StateObject var colorDataController = ColorDataController()!
    @StateObject var photoDataController = PhotoDataController()!
    
    var body: some View {
        NavigationView {
            TabView {
                ColorView(colorController: colorDataController)
                    .tabItem {
                        Label("Color", systemImage: "paintbrush")
                    }
                PhotoView(photoController: photoDataController)
                    .tabItem {
                        Label("Photo", systemImage: "photo")
                    }
                CountView()
                    .tabItem {
                        Label("Count", systemImage: "123.rectangle")
                    }
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
            }
            .navigationTitle("Sync")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button {
                    
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button {
                        
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }        
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
