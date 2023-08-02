//
//  DataController.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import Foundation
import Combine
import CouchbaseLiteSwift

class DataController {
    internal let database: CouchbaseLiteSwift.Database
    internal let collection: CouchbaseLiteSwift.Collection
    private var app: App!
    
    private var cancellables = Set<AnyCancellable>()
    internal var documentChangeListener: ListenerToken!
    
    init?(databaseName: String) {
        database = try! CouchbaseLiteSwift.Database(name: databaseName)
        collection = try! database.defaultCollection()
        
        // Get the identity and CA, then start the app. The app syncs
        // with nearby devices using peer-to-peer and the endpoint
        // specified in the app settings using the Internet.
        Credentials.async { [self] identity, ca in
            app = App(
                database: database,
                endpoint: Settings.shared.endpoint,
                identity: identity,
                ca: ca
            )
            app.start()

            // When the endpoint settings change, update the app.
            Settings.shared.$endpoint
                .dropFirst()
                .sink { [weak self] newEndpoint in
                    self?.app.endpoint = newEndpoint
                }.store(in: &cancellables)
        }        
    }
}
