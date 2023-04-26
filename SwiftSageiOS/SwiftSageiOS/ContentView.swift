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

        GeometryReader { geometry in
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
                .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight : 0)
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
                        Button(action: {
                            withAnimation {
                                screamer.websocket.write(ping: Data())
                            }
                        }) {
                            Image(systemName: "shippingbox.and.arrow.backward")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .padding()
                                .background(settingsViewModel.buttonColor)
                                .foregroundColor(.white)
                                .cornerRadius(30)
                                .padding(.bottom, 10)
                        }
                        .padding()

                        Spacer()
                    }
                }
            }
            .onAppear {
                keyboardObserver.startObserve(height: geometry.size.height)
            }
            .onDisappear {
                keyboardObserver.stopObserve()
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
        @Published var keyboardHeight: CGFloat = 0

        private var screenHeight: CGFloat = 0

        func startObserve(height: CGFloat) {
            screenHeight = height
            NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }

        func stopObserve() {
            NotificationCenter.default.removeObserver(self)
        }

        @objc private func onKeyboardChange(notification: Notification) {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardTop = screenHeight - keyboardFrame.origin.y
                isKeyboardVisible = keyboardTop > 0
                keyboardHeight = max(0, keyboardTop)
            }
        }
    }
}
