//
//  SearchView.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var searchController: SearchDataController
    @State var searchText: String = ""
    @State var searchScope: SearchDataController.SearchScope = .all
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(searchController.results, id: \.self) { searchResult in
                        VStack {
                            Image(uiImage: searchResult.image)
                                .resizable()
                                .scaledToFit()
                            Text(searchResult.name)
                        }
                        .padding()
                    }
                }
                .padding()
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Tops, Bottoms, Shoes and More")
                .searchScopes($searchScope, activation: .onSearchPresentation) {
                    ForEach(SearchDataController.SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue)
                    }
                }
                .onAppear(perform: runSearch)
                .onSubmit(of: .search, runSearch)
                .onChange(of: searchText, perform: { _ in runSearch() })
                .onChange(of: searchScope, perform: { _ in runSearch() })
            }
            .navigationTitle("Search")
            .navigationBarBackButtonHidden(true)
            .withInfoToolbar(infoText: "Search using name, color, category and more")
        }
    }
    
    func runSearch() {
        searchController.search(searchText, category: searchScope)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
