//
//  PhotoDataController.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI
import CouchbaseLiteSwift

class PhotoDataController : DataController, ObservableObject {
    private static let DB_NAME: String = "photo"
    private static let DOC_ID: String = "profile"
    private static let EMOJI_KEY: String = "emoji"
    private static let PHOTO_BLOB_KEY: String = "photo"
    
    @Published var image : UIImage?
    
    init?() {
        super.init(databaseName: PhotoDataController.DB_NAME)
        self.documentChangeListener = collection.addDocumentChangeListener(id: PhotoDataController.DOC_ID) { [weak self] _ in
            self?.updatePhoto()
        }
        updatePhoto()
    }
    
    private func updatePhoto() {
        if let profile = try? self.collection.document(id: PhotoDataController.DOC_ID),
           let imageBlob = profile.blob(forKey: PhotoDataController.PHOTO_BLOB_KEY),
           let imageData = imageBlob.content {
            self.image = UIImage(data: imageData)
        }
    }
    
    @MainActor public func nextPhoto() {
        let profile = collection[PhotoDataController.DOC_ID].document?.toMutable() ?? MutableDocument(id: PhotoDataController.DOC_ID)
        let emoji = profile[PhotoDataController.EMOJI_KEY].string
        let nextEmoji = Photos.nextEmoji(emoji)
        let newPhoto = Photos[nextEmoji]
        
        if let pngData = newPhoto?.pngData() {
            profile[PhotoDataController.EMOJI_KEY].string = nextEmoji
            profile[PhotoDataController.PHOTO_BLOB_KEY].blob = Blob(contentType: "image/png", data: pngData)
            try? collection.save(document: profile)
        }
    }
    
    private class Photos {
        private static let emojis: [String] = ["🦁","🦊","🐻‍❄️","🐱","🐶","🐰"]
        
        @MainActor static subscript(emoji: String) -> UIImage? {
            return image(emoji)
        }
        
        static func nextEmoji(_ emoji: String?) -> String {
            let index = (emoji != nil ? emojis.firstIndex(of: emoji!) : nil) ?? -1
            let nextIndex = (index + 1) % emojis.count
            let nextEmoji = emojis[nextIndex]
            return nextEmoji
        }
        
        private struct EmojiRenderView : View {
            let emojiText: String
            let font: Font = .system(size: 160)
            var body: some View {
                Text(emojiText)
                    .font(font)
            }
        }
        
        @MainActor private static func image(_ emoji: String) -> UIImage? {
            let renderer = ImageRenderer(content: EmojiRenderView(emojiText: emoji))
            return renderer.uiImage
        }
    }
}
