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

    @ObservedObject var settingsViewModel = SettingsViewModel.shared
    init() {
        consoleManager.isVisible = true
        consoleManager.fontSize = settingsViewModel.textSize

    }
    var body: some View {

        ZStack {
            Image("swsLogo")
            .resizable()
            .scaledToFit()
            .padding()
            if let image = settingsViewModel.receivedImage {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.leading, 10)
                    Spacer()
                }
            } else {
                HStack {
                    Text("No image received")
                        .padding(.leading, 10)
                    Spacer()
                }


            }

            VStack {
                Spacer()

                HStack {
        
                    VStack {
                        CommandButtonView(settingsViewModel: settingsViewModel)
                    }
                    

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
                        settingsViewModel.receivedImage = nil
                    }) {
                        Image(systemName: "macbook.and.iphone")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.bottom, 10)
                    }
                    .padding()
                    Button(action: {
                        withAnimation {
                            showSettings.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding()
                            .background(settingsViewModel.buttonColor)
                            .foregroundColor(.white)
                            .cornerRadius(30)
                            .padding(.bottom, 10)
                    }
                    .padding()
                    .popover(isPresented: $showSettings, arrowEdge: .top) {
                        SettingsView(showSettings: $showSettings, viewModel: settingsViewModel)
                        
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
