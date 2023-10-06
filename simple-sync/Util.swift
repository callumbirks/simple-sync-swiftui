//
//  Util.swift
//  simple-sync
//
//  Created by Callum Birks on 06/10/2023.
//

import SwiftUI

struct InfoToolbar: ViewModifier {
    let infoText: String
    @State var infoPresented: Bool = false
    @State var sharePresented: Bool = false
    @State var shareQRPresented: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button {
                        infoPresented = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing)
                {
                    Button {
                        sharePresented = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .confirmationDialog(infoText, isPresented: $infoPresented, titleVisibility: .visible, actions: Actions.info)
            .sheet(isPresented: $sharePresented) {
                Actions.ShareView(isQRPresented: $shareQRPresented)
            }
            .sheet(isPresented: $shareQRPresented, content: Actions.QR)
    }
}

extension View {
    func withInfoToolbar(infoText: String) -> some View {
        modifier(InfoToolbar(infoText: infoText))
    }
}
