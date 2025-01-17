//
//  Document.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI
import SwiftData
import PDFKit

/// SwiftData Model, Holds all the Data about the Scanned Documents
@Model
class Document {
    var documentName: String
    var documentCreation: Date
    @Attribute(.externalStorage) var scannedImages: [Data]
    
    init(documentName: String, documentCreation: Date, scannedImages: [Data]) {
        self.documentName = documentName
        self.documentCreation = documentCreation
        self.scannedImages = scannedImages
    }
    
    /// Converting Entire Scanned Pages to PDF
    func createPDF(updateLoading: @escaping (Bool) -> (), onFinish: @escaping (URL?) -> ()) async {
        updateLoading(true)
        
        /// For Loading Indicator to Display
        try? await Task.sleep(for: .seconds(0.4))
        
        let pdfDocument = PDFDocument()
        for index in scannedImages.indices {
            if let pageImage = UIImage(data: scannedImages[index]),
               let pdfPage = PDFPage(image: pageImage) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }
        
        var pdfURL = FileManager.default.temporaryDirectory
        let fileName = "\(documentName).pdf"
        pdfURL.append(path: fileName)
        
        if pdfDocument.write(to: pdfURL) {
            onFinish(pdfURL)
        } else {
            onFinish(nil)
        }
        
        updateLoading(false)
    }
}
