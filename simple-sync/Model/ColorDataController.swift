//
//  ColorDataController.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI
import CouchbaseLiteSwift

class ColorDataController : DataController, ObservableObject {
    private static let DB_NAME: String = "color"
    private static let DOC_ID: String = "profile"
    private static let COLOR_KEY: String = "color"
    
    @Published var color: Color?
    private var index: Int = -1 {
        didSet {
            self.color = ColorDataController.Colors[index]
        }
    }
    
    init?() {
        super.init(databaseName: ColorDataController.DB_NAME)
        self.documentChangeListener = collection.addDocumentChangeListener(id: ColorDataController.DOC_ID) { [weak self] _ in
            self?.updateColor()
        }
        updateColor()
    }
    
    private func updateColor() {
        if let profile = try? collection.document(id: ColorDataController.DOC_ID) {
            self.index = profile.int(forKey: ColorDataController.COLOR_KEY)
        }
    }
    
    public func nextColor() {
        // Change the profile color.
        let profile = collection[ColorDataController.DOC_ID].document?.toMutable() ?? MutableDocument(id: ColorDataController.DOC_ID)
        let colorIndex = profile[ColorDataController.COLOR_KEY].value as? Int ?? -1
        let newColorIndex = Colors.nextIndex(colorIndex)

        profile[ColorDataController.COLOR_KEY].int = newColorIndex
        try? collection.save(document: profile)
    }
    
    private class Colors {
        private static let colors: [Color] = [.blue, .green, .pink, .purple, .yellow]
        
        static func nextIndex(_ index: Int) -> Int {
            let clampedIndex = index == -1 ? index : clamp(index)
            let nextIndex = (clampedIndex + 1) % colors.count
            return nextIndex
        }

        private static func clamp(_ index: Int) -> Int {
            return max(min(index, colors.count - 1), 0)
        }
        
        public static subscript(_ index: Int) -> Color {
            return colors[clamp(index)]
        }
    }
}
