//
//  ContentView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 28/06/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isFirstTime") private var isFirstLogin: Bool = true
    @AppStorage("isLockedEnabled") private var isLockedEnabled: Bool = false
    @Environment(\.scenePhase) private var phase
    var appLock: AppLock = .init()
    var body: some View {
        DocMainView()
            .environment(appLock)
            .sheet(isPresented: $isFirstLogin, content: {
                IntroScreen()
                    .interactiveDismissDisabled()
            })
            .preferredColorScheme(.dark)
            /// App Lock If Available
            .overlay {
                if (isLockedEnabled && !appLock.isUnlocked) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            if !appLock.isAvailable {
                                Text("App Lock has been enabled by the user, and the FaceID/TouchID permission has been rejected. In order to open the App, please Enable FaceID or TouchID Permission in the App Settings.")
                                    .multilineTextAlignment(.center)
                                    .padding(15)
                                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
                                    .padding(20)
                            }
                        }
                        .contentShape(.rect)
                        .onTapGesture(perform: askPermission)
                        .ignoresSafeArea()
                }
            }
            .onAppear(perform: askPermission)
            .onChange(of: phase, initial: true) { oldValue, newValue in
                if newValue != .active {
                    appLock.isUnlocked = false
                }
                
                if newValue == .active && !appLock.isUnlocked {
                    askPermission()
                }
            }
    }
    
    func askPermission() {
        if appLock.isAvailable && isLockedEnabled {
            appLock.authenticateUser()
        }
    }
}

#Preview {
    ContentView()
}
