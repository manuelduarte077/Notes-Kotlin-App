//
//  DocumentRowView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// Document Row View with some default document actions displayed in the List
struct DocumentRowView: View {
    @Bindable var document: Document
    @FocusState private var showKeyboard: Bool
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationLink(value: document) {
            VStack(alignment: .leading, spacing: 6, content: {
                TextField("Document Name", text: $document.documentName)
                    .focused($showKeyboard)
                    .overlay {
                        Rectangle()
                            .blendMode(.destinationOver)
                    }
                
                Text("Scanned at " + document.documentCreation.formatted(date: .long, time: .omitted))
                    .foregroundStyle(.gray)
            })
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(action: {
//                context.delete(object: document)
                context.delete(document)
                try? context.save()
            }, label: {
                Image(systemName: "trash")
                    .foregroundStyle(.white)
            })
            .tint(.red)
            
            Button(action: {
                showKeyboard = true
            }, label: {
                Image(systemName: "pencil")
                    .foregroundStyle(.white)
            })
            .tint(.blue)
        }
    }
}
