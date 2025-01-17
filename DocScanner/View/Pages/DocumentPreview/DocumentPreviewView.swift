//
//  DocumentPreviewView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// Document Preview
/// By Clicking a Page will Expand to a Paging View, where we can continue to see all the scanned pages in Expanded Manner
/// Bottom Bar allows us to either share or add new pages to the document
struct DocumentPreviewView: View {
    @Bindable var document: Document
    /// Environment Properties
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    /// View Properties
    @State private var isSaving: Bool = false
    /// Scanner Properties
    @State private var showScanner: Bool = false
    /// Export Properties
    @State private var shareConfirmation: Bool = false
    @State private var presentShareSheet: Bool = false
    @State private var exportItem: Any?
    /// Alert Properties
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    /// Grid Re-Ordering Properties
    /// As you can notice, I'm not directly updating the SwiftData Document since Re-ordering Publishes many changes simultaneously and thus can lead to a crash, so I'm re-Ordering on the temporary state and once the re-ordering has been finished, saving the changes to the SwiftData Model.
    @State private var draggablePages: [Data] = []
    @State private var dragData: Data?
    var body: some View {
        ScrollView(.vertical) {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(draggablePages, id: \.self) { imageData in
                    /// Update Thumbnail Size as per your needs
                    let thumbnailSize = CGSize(width: 400, height: 400)
                                                      
                    NavigationLink {
                        DocumentPreviewSlider(
                            document: document,
                            scrollPosition: draggablePages.firstIndex(of: imageData)
                        )
                    } label: {
                        DocumentImageView(
                            imageData: imageData,
                            size: thumbnailSize
                        )
                        .frame(height: 200)
                        .clipShape(.rect(cornerRadius: 10))
                        .contentShape(.rect)
                    }
                    /// If you don't need Page Re-Ordering, then simply comment out both draggable and dropDestination Modifier's
                    .draggable(imageData) {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .onAppear {
                                dragData = imageData
                            }
                    }
                    .dropDestination(for: Data.self) { items, location in
                        /// Updating Data Model Once Re-Ordering Finished
                        if document.scannedImages != draggablePages {
                            document.scannedImages = draggablePages
                        }
                        dragData = nil
                        return false
                    } isTargeted: { status in
                        /// Re-Ordering Items on the Grid
                        if let dragData, status {
                            if let selectedIndex = draggablePages.firstIndex(of: dragData),
                               let targetIndex = draggablePages.firstIndex(of: imageData),
                               selectedIndex != targetIndex{
                                withAnimation(.snappy) {
                                    let target = draggablePages.remove(at: selectedIndex)
                                    draggablePages.insert(target, at: targetIndex)
                                }
                            }
                        }
                    }
                }
            }
            .padding(15)
        }
        .onChange(of: document, initial: true, { oldValue, newValue in
            draggablePages = newValue.scannedImages
        })
        .overlay {
            if document.scannedImages.isEmpty {
                Text("Start Scanning Your Documents!")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle(document.documentName)
        .navigationBarTitleDisplayMode(.inline)
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
                    
                    Button(action: {
                        showScanner.toggle()
                    }, label: {
                        Image(systemName: "doc.viewfinder")
                            .font(.title3)
                    })
                }
            }
        }
        .confirmationDialog("Choose an action", isPresented: $shareConfirmation) {
            Button("Save PDF", action: createPDF)
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
        .fullScreenCover(isPresented: $showScanner, content: {
            ScannerView { error in
                alertMessage = error.localizedDescription
                showAlert.toggle()
            } didCancel: {
                
            } didFinish: { controller, scan in
                isSaving = true
                controller.dismiss(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    var scannedPages: [Data] = []
                    for pageIndex in 0..<scan.pageCount {
                        /// Converting Images to Data Format
                        let pageImage = scan.imageOfPage(at: pageIndex)
                        /// Change CompressionQaulity as per your need
                        guard let pageData = pageImage.jpegData(compressionQuality: 0.7) else { return }
                        scannedPages.append(pageData)
                    }
                    
                    document.scannedImages.append(contentsOf: scannedPages)
                    self.draggablePages = document.scannedImages
                    try? context.save()
                    isSaving = false
                }
            }
            .ignoresSafeArea(.container, edges: .all)
        })
        .overlay {
            if isSaving {
                SavingLoader(hint: "Creating PDF....")
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {  }
    }
    
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
}

#Preview {
    ContentView()
}
