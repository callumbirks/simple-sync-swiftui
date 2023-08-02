//
//  CountDataController.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import Foundation

import SwiftUI
import CouchbaseLiteSwift

class CountDataController : DataController, ObservableObject {
    private static let DB_NAME: String = "count"
    private static let DOC_ID: String = "item"
    private static let COUNT_KEY: String = "count"
    
    @Published var count: Int
    
    init?() {
        self.count = 0
        super.init(databaseName: CountDataController.DB_NAME)
        self.documentChangeListener = collection.addDocumentChangeListener(id: CountDataController.DOC_ID) { [weak self] _ in
            self?.updateCount()
        }
        updateCount()
    }
    
    private func updateCount() {
        if let doc = try? collection.document(id: CountDataController.DOC_ID),
           let counter = doc.counter(forKey: CountDataController.COUNT_KEY) {
            self.count = counter.value
        }
    }
    
    func incrementCount() {
        var saved = false
        while !saved {
            // Read the count from the item doc and increment it.
            let document = collection[CountDataController.DOC_ID].document?.toMutable() ?? MutableDocument(id: CountDataController.DOC_ID)
            let count: MutableCounter = document.counter(forKey: CountDataController.COUNT_KEY, actor: database.uuid)
            count.increment(by: 1)
            
            // Save with concurrency control and retry on failure.
            saved = (try? collection.save(document: document, concurrencyControl: .failOnConflict)) ?? false
        }
    }
    
    func decrementCount() {
        var saved = false
        while !saved {
            // Read the count from the item doc and decrement it.
            let document = collection[CountDataController.DOC_ID].document?.toMutable() ?? MutableDocument(id: CountDataController.DOC_ID)
            let count: MutableCounter = document.counter(forKey: CountDataController.COUNT_KEY, actor: database.uuid)
            count.decrement(by: 1)
            
            // Save with concurrency control and retry on failure.
            saved = (try? collection.save(document: document, concurrencyControl: .failOnConflict)) ?? false
        }
    }
}
