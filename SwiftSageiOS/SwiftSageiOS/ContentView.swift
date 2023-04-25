//
//  ContentView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Foundation
import Combine

let consoleManager = LCManager.shared

struct ContentView: View {

    @State private var isLabelVisible: Bool = true
    @State private var text: String = "Tap to edit"
    @FocusState private var isTextFieldFocused: Bool

    @StateObject private var keyboardObserver = KeyboardObserver()
    init() {
        consoleManager.isVisible = true
    }
    var body: some View {
        VStack {
            Spacer()
//            Button("LOG") {
//                consoleManager.isVisible = true
//                consoleManager.print("Swifty!")
//                consoleManager.print("Swifty!")
//
//                consoleManager.print("Swifty!")
//
//            }
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)


            VStack {
                if isLabelVisible {
                    Text(text)
                        .font(.largeTitle)
                        .onTapGesture {
                            isLabelVisible = false
                            isTextFieldFocused = true
                        }
                } else {
                    TextField("Tap to edit", text: $text, prompt: Text("Tap to edit"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isLabelVisible = true
                            isTextFieldFocused = false
                        }

                    Button("reset") {
                        // reset term to default pos
                    }
                }
            }
            .animation(.default, value: isLabelVisible)

//            Text("🚀🔥 Welcome to SwiftSage 🧠💥")
//                .foregroundColor(.black)
//                .font(.largeTitle)
//                .fontWeight(.heavy)

        }
        .padding(.bottom, keyboardObserver.isKeyboardVisible ? 270 : 0) // Adjust this value based on the actual keyboard height
        .animation(.easeInOut(duration: 0.25), value: keyboardObserver.isKeyboardVisible)
        .environmentObject(keyboardObserver)
        .padding()
    }
}

class KeyboardObserver: ObservableObject {
    @Published var isKeyboardVisible = false
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .map { _ in true }
            .assign(to: &$isKeyboardVisible)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in false }
            .assign(to: &$isKeyboardVisible)
    }
}
