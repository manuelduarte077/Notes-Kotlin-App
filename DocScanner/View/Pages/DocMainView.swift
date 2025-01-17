//
//  DocMainView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI
import SwiftData

struct DocMainView: View {
    @Environment(AppLock.self) var appLock: AppLock
    /// Persistant Properties
    @Query(sort: [
        SortDescriptor(\Document.documentCreation, order: .reverse)
    ], animation: .snappy) private var scannedDocuments: [Document]
    @Environment(\.modelContext) private var context
    /// View Properties
    @State private var openScanner: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isSaving: Bool = false
    @AppStorage("isLockedEnabled") private var isLockedEnabled: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(scannedDocuments) { doc in
                    DocumentRowView(document: doc)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .bottomTrailing, content: {
                Button(action: {
                    openScanner = true
                }, label: {
                    Image(systemName: "doc.viewfinder")
                        .font(.title)
                        .frame(width: 65, height: 65)
                        .foregroundStyle(.white)
                        .background(.indigo.gradient, in: .circle)
                        .contentShape(.circle)
                })
                .padding(15)
            })
            .navigationTitle("DocScanner")
            .navigationDestination(for: Document.self) { document in
                DocumentPreviewView(document: document)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if appLock.checkForPermission() {
                            isLockedEnabled.toggle()
                            if isLockedEnabled {
                                appLock.authenticateUser()
                            }
                        } else {
                            alertMessage = "Please enable FaceID/TouchID Permission"
                            showAlert.toggle()
                        }
                    } label: {
                        Image(systemName: isLockedEnabled ? "lock" : "lock.open")
                            .font(.title3)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $openScanner) {
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
                    
                    let document = Document(documentName: "New Document", documentCreation: .init(), scannedImages: scannedPages)
                    context.insert(document)
                    try? context.save()
                    isSaving = false
                }
            }
            .ignoresSafeArea(.container, edges: .all)
        }
        .alert(alertMessage, isPresented: $showAlert) {  }
        .overlay {
            if isSaving {
                SavingLoader()
            }
        }
    }
}

#Preview {
    ContentView()
}
