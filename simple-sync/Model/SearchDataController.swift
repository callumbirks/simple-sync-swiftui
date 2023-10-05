//
//  SearchDataController.swift
//  simple-sync
//
//  Created by Callum Birks on 05/10/2023.
//

import Foundation
import SwiftUI
import CouchbaseLiteSwift

class SearchDataController : ObservableObject {
    private static let DB_NAME: String = "search"
    
    public struct SearchResult: Hashable {
        let name: String
        let image: UIImage
    }
    
    public enum SearchScope: String, CaseIterable {
        case all = "All"
        case tops = "Tops"
        case bottoms = "Bottoms"
        case shoes = "Shoes"
    }
    
    @Published var results: Array<SearchResult>
    private let database: Database
    private let collection: Collection
    private let query: Query
    private let queryWithSearch: Query
    
    init?() {
        self.results = []
        
        self.database = try! Database(name: Self.DB_NAME)
        self.collection = try! database.defaultCollection()
        
        if(collection.count == 0) {
            Self.addDemoData(to: collection)
        }
        
        // Initialize the value index on the "name" field for fast sorting.
        let nameIndex = ValueIndexConfiguration(["name"])
        try! collection.createIndex(withName: "NameIndex", config: nameIndex)

        // Initialize the value index on the "category" field for fast predicates.
        let categoryIndex = ValueIndexConfiguration(["category"])
        try! collection.createIndex(withName: "CategoryIndex", config: categoryIndex)

        // Initialize the full-text search index on the "name", "color", and "category" fields.
        let ftsIndex = FullTextIndexConfiguration(["name", "color", "category"])
        try! collection.createIndex(withName: "NameColorAndCategoryIndex", config: ftsIndex)

        // Initialize the default query.
        query = try! database.createQuery("""
            SELECT name, image
            FROM _
            WHERE type = 'product'
                AND ($category IS MISSING OR category = $category OR ARRAY_CONTAINS(category, $category))
            ORDER BY name
        """)

        // Initialize the query with search.
        queryWithSearch = try! database.createQuery("""
            SELECT name, image
            FROM _
            WHERE type = 'product'
                AND ($category IS MISSING OR category = $category OR ARRAY_CONTAINS(category, $category))
                AND MATCH(NameColorAndCategoryIndex, $search)
            ORDER BY RANK(NameColorAndCategoryIndex), name
        """)
    }
    
    public func search(_ searchString: String?, category: SearchScope) {
        // Get the default query.
        var query = query
        
        // Create query parameters.
        let parameters = Parameters()

        // If there is a search value, use the query with search and add the
        // search parameter.
        if var searchString = searchString?.uppercased(), !searchString.isEmpty {
            query = queryWithSearch
            if !searchString.hasSuffix("*") {
                searchString = searchString.appending("*")
            }
            parameters.setString(searchString, forName: "search")
        }

        // If there is a selected category, add the category parameter.
        if category != .all {
            parameters.setString(category.rawValue, forName: "category")
        }

        // Set the query parameters.
        query.parameters = parameters

        do {
            // Execute the query and get the results.
            let queryResults = try query.execute()
            
            // Enumerate through the query results and get the name and image.
            var searchResults: [SearchResult] = []
            for result in queryResults {
                if let name = result["name"].string,
                   let imageData = result["image"].blob?.content,
                   let image = UIImage(data: imageData)
                {
                    let searchResult = SearchResult(name: name, image: image)
                    searchResults.append(searchResult)
                }
            }
            
            // Set the search results.
            self.results = searchResults
        } catch {
            // If the query fails, set an empty result. This is expected when the user is
            // typing an FTS expression but they haven't completed typing so the query is
            // invalid. e.g. "(blue OR"
            self.results = []
        }
    }
    
    private static func addDemoData(to collection: CouchbaseLiteSwift.Collection) {
        let demoData: [[String : Any]] = [
            ["type":"product","name":"Polo","image":"👕","color":"blue","category":"Tops"],
            ["type":"product","name":"Jeans","image":"👖","color":"blue","category":"Bottoms"],
            ["type":"product","name":"Blouse","image":"👚","color":"pink","category":"Tops"],
            ["type":"product","name":"Dress","image":"👗","color":["green", "red"],"category":["Tops", "Bottoms"]],
            ["type":"product","name":"Shorts","image":"🩳","color":["orange", "white", "red"],"category":"Bottoms"],
            ["type":"product","name":"Socks","image":"🧦","color":["brown", "red"]],
            ["type":"product","name":"Hat","image":"🧢","color":"blue"],
            ["type":"product","name":"Scarf","image":"🧣","color":"red"],
            ["type":"product","name":"Gloves","image":"🧤","color":"green"],
            ["type":"product","name":"Coat","image":"🧥","color":"brown","category":"Tops"],
            ["type":"product","name":"Shirt","image":"👔","color":["blue", "yellow"],"category":"Tops"],
            ["type":"product","name":"Trainer","image":"👟","color":["gray", "white"],"category":"Shoes"],
            ["type":"product","name":"Flat","image":"🥿","color":"blue","category":"Shoes"],
            ["type":"product","name":"Hiking Boot","image":"🥾","color":["orange", "brown", "green"],"category":"Shoes"],
            ["type":"product","name":"Loafer","image":"👞","color":"brown","category":"Shoes"],
            ["type":"product","name":"Boot","image":"👢","color":"brown","category":"Shoes"],
            ["type":"product","name":"Sandal","image":"👡","color":"brown","category":"Shoes"],
            ["type":"product","name":"Flip Flop","image":"🩴","color":["green", "blue"],"category":"Shoes"]
        ]
        
        func image(fromString string: String) -> UIImage? {
            let nsString = string as NSString
            let font = UIFont.systemFont(ofSize: 160)
            let stringAttributes = [NSAttributedString.Key.font: font]
            let imageSize = nsString.size(withAttributes: stringAttributes)

            let renderer = UIGraphicsImageRenderer(size: imageSize)
            let image = renderer.image { _ in
                nsString.draw( at: CGPoint.zero, withAttributes: stringAttributes)
            }

            return image
        }
        
        for (_, data) in demoData.enumerated() {
            let document = MutableDocument(data: data)
            if let imageString = document["image"].string {
                let image = image(fromString: imageString)
                // Convert image to pngData
                if let pngData = image?.pngData() {
                    document["image"].blob = Blob(contentType: "image/png", data: pngData)
                }
            }
            try! collection.save(document: document)
        }
    }
}
