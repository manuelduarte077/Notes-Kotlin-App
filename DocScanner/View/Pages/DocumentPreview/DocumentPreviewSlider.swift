//
//  DocumentPreviewSlider.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// When Clicking a page, This view will be opened and displays all the scanned pages in Paging Manner
struct DocumentPreviewSlider: View {
    @Bindable var document: Document
    @Environment(\.dismiss) private var dismiss
    /// View Properties
    @State var scrollPosition: Int?
    @State private var isSaving: Bool = false
    /// Export Properties
    @State private var shareConfirmation: Bool = false
    @State private var presentShareSheet: Bool = false
    @State private var exportItem: Any?
    /// Alert Properties
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            TabView(selection: $scrollPosition) {
                ForEach(document.scannedImages, id: \.self) { imageData in
                    DocumentImageView(
                        imageData: imageData,
                        size: size,
                        contentMode: .fit
                    )
                    .tag(document.scannedImages.firstIndex(of: imageData))
                    .padding(15)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(action: {
                        shareConfirmation.toggle()
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                    })
                    
                    Spacer(minLength: 0)
                    
                    Button(action: deletePage) {
                        Image(systemName: "trash")
                            .font(.title3)
                    }
                }
            }
        }
        .confirmationDialog("Choose an action", isPresented: $shareConfirmation) {
            if let scrollPosition, document.scannedImages.indices.contains(scrollPosition) {
                Button("Save \(navTitle)") {
                    createPageImage(document.scannedImages[scrollPosition])
                }
            }
            
            Button("Save Entire Document") {
                createPDF()
            }
        }
        .sheet(isPresented: $presentShareSheet, onDismiss: {
            if let pdfDocumentURL = exportItem as? URL {
                try? FileManager.default.removeItem(at: pdfDocumentURL)
                exportItem = nil
            } else {
                exportItem = nil
            }
        }, content: {
            ShareSheet(items: [exportItem])
        })
        .overlay {
            if isSaving {
                SavingLoader(hint: "Creating PDF...")
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {  }
    }
    
    /// Returns Currently Active Page in Paging Slider
    var navTitle: String {
        if let scrollPosition {
            return "Page \(scrollPosition + 1)"
        }
        
        return ""
    }
    
    /// Converting Entire Scanned Pages to PDF
    func createPDF() {
        Task {
            await document.createPDF { status in
                isSaving = status
            } onFinish: { url in
                if let url {
                    exportItem = url
                    presentShareSheet.toggle()
                } else {
                    alertMessage = "Problem in Saving PDF Document"
                    showAlert.toggle()
                }
            }
        }
    }
    
    /// Creates Image for the Current Page
    func createPageImage(_ imageData: Data) {
        if let pageImage = UIImage(data: imageData) {
            exportItem = pageImage
            presentShareSheet.toggle()
        } else {
            alertMessage = "Problem in creating Page Image"
            showAlert.toggle()
        }
    }
    
    /// Deleting Current Page
    func deletePage() {
        /// If you have any problems with the Page deletion, then simply remove the page from the main queue.
        DispatchQueue.global(qos: .userInteractive).async {
            if let scrollPosition, document.scannedImages.indices.contains(scrollPosition) {
                document.scannedImages.remove(at: scrollPosition)
                
                DispatchQueue.main.async {
                    if document.scannedImages.isEmpty {
                        dismiss()
                    } else {
                        /// If the page is the last one, then the TabView is pushing it to the front view (0th Index), so in order to avoid this, I'm manually setting the active Page to the previously available page.
                        if document.scannedImages.indices.contains(scrollPosition - 1) && scrollPosition == document.scannedImages.count - 2 {
                            self.scrollPosition = scrollPosition - 1
                        }
                    }
                }
            }
        }
    }
}
