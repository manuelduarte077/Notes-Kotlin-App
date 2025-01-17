//
//  ScannerView.swift
//  DocScanner
//
//  Created by Manuel Duarte on 29/06/24.
//

import SwiftUI
import VisionKit

/// Scanner View Using VisionKit
/// This ViewController by default contains all necessary tools for Scanning Documents
struct ScannerView: UIViewControllerRepresentable {
    var didFailedWithError: (Error) -> ()
    var didCancel: () -> ()
    var didFinish: (VNDocumentCameraViewController, VNDocumentCameraScan) -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: ScannerView
        init(parent: ScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            parent.didFinish(controller, scan)
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
            parent.didCancel()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.didFailedWithError(error)
            controller.dismiss(animated: true)
        }
    }
}
