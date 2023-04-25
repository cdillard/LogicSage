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
    @State private var showSettings = false
    @State private var isLabelVisible: Bool = true
    @FocusState private var isTextFieldFocused: Bool

    @StateObject private var keyboardObserver = KeyboardObserver()

    @ObservedObject var viewModel = SettingsViewModel()
    
    init() {
        consoleManager.isVisible = true
    }
    var body: some View {

        ZStack {
            VStack {
                Spacer()

                HStack {
                    //                Button("FORCE 📵🔌 📶") {
                    //                    print("FORCING WEBSOCKET CONNECTION")
                    //                }
                    //                .font(.body)
                    //                .foregroundColor(Color.white)
                    //                .padding()
                    //                .background(Color.red)
                    //                .cornerRadius(10)
                    VStack {
                        CommandButtonView()
                    }
                    //            Text("🚀🔥 Welcome to SwiftSage 🧠💥")
                    //                .foregroundColor(.black)
                    //                .font(.largeTitle)
                    //                .fontWeight(.heavy)
                }
            }
            .padding(.bottom, keyboardObserver.isKeyboardVisible ? 0 : 0) // Adjust this value based on the actual keyboard height
            .animation(.easeInOut(duration: 0.25), value: keyboardObserver.isKeyboardVisible)
            .environmentObject(keyboardObserver)
            .padding()
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        withAnimation {
                            showSettings.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                    }
                    .padding()
                    .popover(isPresented: $showSettings, arrowEdge: .top) {
                        SettingsView(showSettings: $showSettings, viewModel: viewModel)
                    }
                    Spacer()
                }
            }
        }
        .onChange(of: showSettings) { newValue in
            if newValue {
                print("Popover is shown")
                consoleManager.isVisible = false
            } else {
                print("Popover is hidden")
                consoleManager.isVisible = true

            }
        }

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
