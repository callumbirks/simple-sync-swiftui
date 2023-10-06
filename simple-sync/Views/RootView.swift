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
    @StateObject var countDataController = CountDataController()!
    @StateObject var searchDataController = SearchDataController()!
    
    var body: some View {
        TabView {
            ColorView(colorController: colorDataController)
                .tabItem {
                    Label("Color", systemImage: "paintbrush")
                }
            PhotoView(photoController: photoDataController)
                .tabItem {
                    Label("Photo", systemImage: "photo")
                }
            CountView(countController: countDataController)
                .tabItem {
                    Label("Count", systemImage: "123.rectangle")
                }
            SearchView(searchController: searchDataController)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
