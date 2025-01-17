//
//  SavingLoader.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// A Loading Indicator
struct SavingLoader: View {
    var hint: String = "Saving Document..."
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.35))
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.black)
                    .scaleEffect(1.6)
                    .frame(height: 45)
                
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .padding(15)
            .background(.white, in: .rect(cornerRadius: 10))
        }
    }
}

#Preview {
    SavingLoader()
}
