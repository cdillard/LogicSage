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
                            .padding(.leading,geometry.size.width * 0.01)
                        Spacer()
                    }
                } else {
                    HStack {
                        Text("Restart app if you encounter any issues, OK?\nFresh install if terminal becomes too small :(")
                            .padding(.leading,geometry.size.width * 0.01)
                            .padding(.top,geometry.size.width * 0.01)

                        Spacer()
                    }


                }

                VStack {
                    Spacer()
                    CommandButtonView(settingsViewModel: settingsViewModel)
                }
                .padding(.bottom, keyboardObserver.isKeyboardVisible ? keyboardObserver.keyboardHeight : 0)
                .animation(.easeInOut(duration: 0.25), value: keyboardObserver.isKeyboardVisible)
                .environmentObject(keyboardObserver)
                .padding(.bottom, geometry.size.width * 0.01)


                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            settingsViewModel.receivedImage = nil
                        }) {

                            resizableButtonImage(systemName: "macbook.and.iphone", size: geometry.size)

                        }
                        .padding(geometry.size.width * 0.01)
                        Button(action: {
                            withAnimation {
                                showSettings.toggle()
                            }
                        }) {
                            resizableButtonImage(systemName: "gearshape", size: geometry.size)

                        }
                        .padding(geometry.size.width * 0.01)
                        .popover(isPresented: $showSettings, arrowEdge: .top) {
                            SettingsView(showSettings: $showSettings, viewModel: settingsViewModel)

                        }
                        Button(action: {
                            withAnimation {
                                screamer.websocket.write(ping: Data())
                            }
                        }) {

                            resizableButtonImage(systemName: "shippingbox.and.arrow.backward", size: geometry.size)
                        }
                        .padding(geometry.size.width * 0.01)
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
    let maxButtonSize: CGFloat = 20

    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: min(size.width * 0.05, maxButtonSize), height: min(size.width * 0.05, maxButtonSize))
            .padding(size.width * 0.02)
            .background(settingsViewModel.buttonColor)
            .foregroundColor(.white)
            .cornerRadius(size.width * 0.05)
            .padding(.bottom, size.width * 0.01)
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
