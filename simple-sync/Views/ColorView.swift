//
//  ColorView.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI

struct ColorView: View {
    @ObservedObject var colorController: ColorDataController
    private var color: Color? {
        colorController.color
    }
    
    var body: some View {
        NavigationView {
            Button {
                colorController.nextColor()
            } label: {
                Circle()
                    .foregroundColor(color ?? .gray)
            }
            .frame(maxWidth: 300, maxHeight: 300)
            .navigationTitle("Sync")
            .navigationBarBackButtonHidden(true)
            .withInfoToolbar()
        }
    }
}

struct ColorView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
