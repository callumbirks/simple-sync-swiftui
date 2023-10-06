//
//  Actions.swift
//  simple-sync
//
//  Created by Wayne Carter on 7/7/23.
//

import UIKit
import SwiftUI
import CoreImage.CIFilterBuiltins

class Actions {
    @ViewBuilder public static func info() -> some View {
        Link("Explore the Code", destination: URL(string: "https://github.com/waynecarter/simple-sync/")!)
        Link("Settings", destination: URL(string: UIApplication.openSettingsURLString)!)
        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        Link("Privacy Policy", destination: URL(string: "https://github.com/waynecarter/simple-sync/blob/main/PRIVACY")!)
        Button("Cancel", role: .cancel) {}
    }
    
    private static let appStoreURL = "https://apps.apple.com/us/app/simple-data-sync/id6449199482"
    
    public struct ShareView: UIViewControllerRepresentable {
        @Binding var isQRPresented: Bool
        
        public typealias UIViewControllerType = UIActivityViewController
        
        public func makeUIViewController(context: Context) -> UIActivityViewController {
            let qrCodeActivity = QRCodeActivity(isQRPresented: $isQRPresented, appURL: appStoreURL)
            
            let activityViewController = UIActivityViewController(activityItems: [appStoreURL], applicationActivities: [qrCodeActivity])
            
            return activityViewController
        }
        
        public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        }
    }
    
    private static let context = CIContext()
    private static let qrImage: UIImage = {
        // Create the QR code image.
        let data = Data(appStoreURL.utf8)
        let filter = CIFilter.qrCodeGenerator()
        
        filter.setValue(data, forKey: "inputMessage")

        let transform = CGAffineTransform(scaleX: 10, y: 10)

        if let output = filter.outputImage?.transformed(by: transform),
           let image = context.createCGImage(output, from: output.extent){
            return UIImage(cgImage: image)
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }()
    
    @ViewBuilder public static func QR() -> some View {
        VStack {
            Text("Simple Sync").font(.title3).bold()
            Text("Scan the QR code to get the app")
            Image(uiImage: qrImage)
            .resizable()
            .scaledToFit()
            .padding(10)
            .background(.white)
            .cornerRadius(10)
            .padding([.horizontal], 40)
        }
    }
    
    private class QRCodeActivity: UIActivity {
        @Binding var isQRPresented: Bool
        private let appURL: String
        
        init(isQRPresented: Binding<Bool>, appURL: String) {
            self._isQRPresented = isQRPresented
            self.appURL = appURL
        }
        
        override var activityTitle: String? {
            return "Show QR Code"
        }
        
        override var activityImage: UIImage? {
            return UIImage(systemName: "qrcode")
        }
        
        override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
            return true
        }
        
        override func perform() {
            isQRPresented = true
            
            activityDidFinish(true)
        }
    }
}
