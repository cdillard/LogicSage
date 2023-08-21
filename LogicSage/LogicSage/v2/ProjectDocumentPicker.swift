//
//  ProjectDocumentPicker.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//

import Foundation
import SwiftUI
import UIKit

struct ProjectDocumentPicker: UIViewControllerRepresentable {
    @Binding var pickedDocumentURL: URL?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.dt.document.workspace", "public.wrapper-xcode-project"], in: .import)
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = false
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Nothing to update
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: ProjectDocumentPicker
        init(_ parent: ProjectDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.pickedDocumentURL = urls.first
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
