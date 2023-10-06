//
//  PhotoView.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI

struct PhotoView: View {
    @ObservedObject var photoController : PhotoDataController
    private var image: UIImage? {
        photoController.image
    }
    
    var body: some View {
        NavigationView {
            Button {
                photoController.nextPhoto()
            } label: {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    Text("No image")
                }
            }
            .frame(maxWidth: 160.0, maxHeight: 160.0)
            .navigationTitle("Sync")
            .navigationBarBackButtonHidden(true)
            .withInfoToolbar(infoText: "Tap the screen, change the photo, and sync with devices around you")
        }
    }
}

struct PhotoView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
