//
//  AppLock.swift
//  DocScanner
//
//  Created by Manuel Duarte on 28/06/24.
//

import SwiftUI
import LocalAuthentication
import SwiftData

/// Face/Touch Lock Properties
@Observable
class AppLock {
    var isUnlocked: Bool = false
    var isAvailable: Bool = true
    
    /// Authenticating With User
    func authenticateUser(){
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Security To Hide Privacy Contents From Others") { status, _ in
                DispatchQueue.main.async {
                    self.isUnlocked = status
                }
            }
        } else {
            isAvailable = false
            isUnlocked = false
        }
    }
    
    func checkForPermission() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
