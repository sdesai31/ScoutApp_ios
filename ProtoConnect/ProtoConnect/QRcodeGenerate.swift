//
//  QRcodePage.swift
//  ProtoConnect
//
//  Created by Akarsh Shetty on 3/27/24.
//

import Foundation
import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRcodeGenerate: View {
    let filter = CIFilter.qrCodeGenerator()
    @Binding var data: String
    let contex = CIContext()
    
    var body: some View {
        Image(uiImage: qrGenerate(data))
            .interpolation(.none)
            .resizable()
            .frame(width: 150, height: 150, alignment: .center)
    }
    
    func qrGenerate (_ qrdata: String)->UIImage{
        let data = Data(qrdata.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCode1 = filter.outputImage {
            if let qrcodeImage = contex.createCGImage(qrCode1, from: qrCode1.extent){
                return UIImage(cgImage: qrcodeImage)
            }
        }
        
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}
