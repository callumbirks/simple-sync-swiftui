//
//  CountView.swift
//  simple-sync
//
//  Created by Callum Birks on 02/08/2023.
//

import SwiftUI

struct CountView: View {
    @ObservedObject var countController : CountDataController
    private var count: Int {
        countController.count
    }
    
    var body: some View {
        VStack {
            Button {
                countController.incrementCount()
            } label: {
                CountButtonLabel(symbolName: "plus")
            }
            Text(String(count))
                .font(.system(size: 120))
            Button {
                countController.decrementCount()
            } label: {
                CountButtonLabel(symbolName: "minus")
            }
        }
    }
}

struct CountButtonLabel: View {
    let symbolName: String
    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: 48))
            .foregroundColor(.white)
            .frame(width: 120, height: 120)
            .background {
                RoundedRectangle(cornerRadius: 10)
            }
    }
}

struct CountView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
