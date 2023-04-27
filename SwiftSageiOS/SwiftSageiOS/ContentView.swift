//
//  ContentView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Foundation
import Combine

let consoleManager = LCManager.shared//cmdWindows[0]

struct ContentView: View {
    @State private var showSettings = false
    @State private var isLabelVisible: Bool = true
    @State private var  code: String = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0

    @StateObject private var keyboardObserver = KeyboardObserver()

    @ObservedObject var settingsViewModel = SettingsViewModel.shared


    @State private var showAddView = false

    @State var theCode: String


    @State private var currentEditorScale: CGFloat = 1.0
    @State private var lastEditorScaleValue: CGFloat = 1.0
    @State private var positionEditor: CGSize = CGSize.zero


    init() {
        
        theCode  = """
struct WaveView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let waveCount = 6
                ForEach(0..<waveCount) { index in
                    Path { p in
                        let x: CGFloat = CGFloat(index) / CGFloat(waveCount)
                        let y = CGFloat(sin((.pi * 2 * Double(x)) - (Double(geometry.frame(in: .local).minX) / 100))) / 3
                        p.move(to: CGPoint(x: geometry.frame(in: .local).minX, y: (1 + y) * geometry.frame(in: .local).height / 2))
                        for x in stride(from: geometry.frame(in:.local).minX, to: geometry.frame(in:.local).maxX, by: 4) {
                            let y = CGFloat(sin((.pi * 2 * Double(x/100)) + (Double(index) * .pi / 3) - (Double(geometry.frame(in: .local).minX) / 100))) / 3
                            p.addLine(to: CGPoint(x:x, y: (1 + y) * geometry.frame(in: .local).height / 2))
                        }
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).maxX, y:geometry.frame(in:.local).maxY))
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).minX, y:geometry.frame(in:.local).maxY))
                        p.addLine(to: CGPoint(x:geometry.frame(in:.local).minX, y:(1 - y) * geometry.frame(in: .local).height / 2))
                    }
                    .fill(Color(red: Double(index) / Double(waveCount), green: Double((waveCount - index) / waveCount), blue: 1.0 - Double(index) / Double(waveCount)))
                    .opacity(0.5)
                }
            }
        }
    }
}
"""
        consoleManager.isVisible = true
        consoleManager.fontSize = settingsViewModel.textSize

    }
    var body: some View {

        GeometryReader { geometry in
            ZStack {
                // SOURCE CODE EDITOR HANDLE
                ZStack {
                    if settingsViewModel.isEditorVisible {
                        
                        HandleView()
                            .zIndex(2) // Add zIndex to ensure it's above the SageWebView
                            .offset(x: -12, y: -12) // Adjust the offset values
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        positionEditor = CGSize(width: positionEditor.width + value.translation.width, height: positionEditor.height + value.translation.height)
                                    }
                                    .onEnded { value in
                                        // No need to reset the translation value, as it's read-only
                                    }
                            )
                            .onTapGesture {
                                print("Tapped on the handle")
                            }
                    }

                    Image("swsLogo")
                        .resizable()
                        .scaledToFit()
                        .padding()

                    // HANDLE SOURCE CODE EDITOR
                    if settingsViewModel.isEditorVisible {

                        SourceCodeTextEditor(text: $theCode)
                            .scaleEffect(currentScale)
                            .offset(positionEditor)

                            .gesture(
                                MagnificationGesture()
                                    .onChanged { scaleValue in
                                        // Update the current scale based on the gesture's scale value
                                        currentScale = lastScaleValue * scaleValue
                                    }
                                    .onEnded { scaleValue in
                                        // Save the scale value when the gesture ends
                                        lastScaleValue = currentScale
                                    }
                            )
                    }
                }
                .offset(positionEditor)

                // HANDLE WEBVIEW
                if settingsViewModel.showWebView {
                    SageWebView()
                }


                // HANDLE SIMULATOR
                if let image = settingsViewModel.receivedImage {
                    HStack {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading,geometry.size.width * 0.01)
                        Spacer()
                    }
                } else {
                    VStack {
                        HStack {
                            Spacer()

                            Text("Restart app if you encounter any issues, OK?\nFresh install if terminal becomes too small :(")

                        }
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
                            if settingsViewModel.isEditorVisible {
                                consoleManager.isVisible = true
                            } else {
                                consoleManager.isVisible = false

                            }
                            // For all windowzzz...


                            // TODO
                            settingsViewModel.isEditorVisible = !settingsViewModel.isEditorVisible
                            // TODO: remove test reset here
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
                                screamer.websocket.write(ping: Data())
                                consoleManager.print("ping...")
                                print("ping...")
                        }) {

                            resizableButtonImage(systemName: "shippingbox.and.arrow.backward", size: geometry.size)
                        }
                        .padding(geometry.size.width * 0.01)
                        Button(action: {


                            showAddView.toggle()


                            // window 1 is for second cmd prompt
                        }) {

                            resizableButtonImage(systemName: "plus.rectangle", size: geometry.size)
                        }
                        .padding(geometry.size.width * 0.01)
                        Spacer()
                            .popover(isPresented: $showAddView, arrowEdge: .top) {
                                AddView(showAddView: $showAddView, viewModel: settingsViewModel)

                            }
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
