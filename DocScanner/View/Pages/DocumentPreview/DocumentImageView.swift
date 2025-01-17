//
//  DocumentImageView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// An Optimised Image View for displaying Scanned Contents
struct DocumentImageView: View {
    var imageData: Data
    var size: CGSize
    var contentMode: ContentMode = .fill
    @State private var thumbnailImage: UIImage?
    var body: some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                if let thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .frame(width: size.width, height: size.height)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .task {
            guard thumbnailImage == nil else { return }
            thumbnailImage = await UIImage(data: imageData)?.byPreparingThumbnail(ofSize: size)
        }
    }
}
