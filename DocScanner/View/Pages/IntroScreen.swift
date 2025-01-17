//
//  IntroScreen.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI

/// An Intro Screen, Inspired from Apple Designed Apps
struct IntroScreen: View {
    @AppStorage("isFirstTime") private var isFirstLogin: Bool = true
    var body: some View {
        VStack(spacing: 15) {
            Text("What's New in \nDocScanner")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 65)
                .padding(.bottom, 35)
            
            VStack(alignment: .leading, spacing: 25, content: {
                HStack(spacing: 15) {
                    Image(systemName: "scanner")
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)
                    
                    VStack(alignment: .leading, spacing: 6, content: {
                        Text("Scan Documents")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Scan any document with ease.")
                            .foregroundStyle(.gray)
                    })
                }
                
                HStack(spacing: 15) {
                    Image(systemName: "tray.full.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)
                    
                    VStack(alignment: .leading, spacing: 6, content: {
                        Text("Save Documents")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Persist scanned documents with the new SwiftData Model.")
                            .foregroundStyle(.gray)
                    })
                }
                
                HStack(spacing: 15) {
                    Image(systemName: "faceid")
                        .font(.largeTitle)
                        .foregroundStyle(.indigo)
                    
                    VStack(alignment: .leading, spacing: 6, content: {
                        Text("Lock Documents")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Protect your documents so that only you can Unlock them using FaceID.")
                            .foregroundStyle(.gray)
                    })
                }
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 25)
            
            Spacer()
            
            Button(action: {
                isFirstLogin = false
            }, label: {
                Text("Continue")
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.indigo, in: .rect(cornerRadius: 12))
            })
        }
        .padding()
    }
}
