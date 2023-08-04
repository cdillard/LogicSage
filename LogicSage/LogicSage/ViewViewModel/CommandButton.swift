//
//  CommandButton.swift
//  LogicSage
//
//  Created by Chris Dillard on 4/24/23.
//

import Foundation
import SwiftUI

struct CommandButtonView: View {
    @EnvironmentObject var appModel: AppModel

    @StateObject var settingsViewModel: SettingsViewModel
    @State var textEditorHeight : CGFloat = 20
    @ObservedObject var windowManager: WindowManager
    @Binding var isInputViewShown: Bool

//    @State private var isFilePickerShown = false
//    @State private var picker = DocumentPicker()

    func openText() {
        isInputViewShown.toggle()
    }
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0)  {
                HStack {
#if os(xrOS)
                    ToggleImmersiveButton(idOfView: "ImmersiveSpaceVolume", name: "3D WindowSphere", showImmersiveLogo: $appModel.isShowingImmersiveWindow)
                    ToggleImmersiveButton(idOfView: "LogoVolume", name: "3D Logo", showImmersiveLogo: $appModel.isShowingImmersiveLogo)
                    //                    ToggleImmersion(showImmersiveSpace: $appModel.isShowingImmersiveScene)
#endif
                }
                Spacer()
                HStack(spacing: 4) {
                    Spacer()


#if targetEnvironment(macCatalyst)

                    Button(action: {
                        if !appModel.isServerActive {
                            DispatchQueue.main.async {
                                // Execute your action here
                                
                                Backend.doBackend(path: "~/LogicSage/")
                                //appModel.isServerActive = true
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                               print("killall swifty-gpt")
                            }
                        }
                    }) {
                        VStack(spacing: 0)  {

                            resizableButtonImage(systemName:
                                                    "server.rack",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text( "Start server" )
                          //  Text("\(appModel.isServerActive ? "Stop" : "Start") server" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif
                    }
                    .buttonStyle(MyButtonStyle())

                    #endif


                    Button(action: {
                        DispatchQueue.main.async {
                            // Execute your action here
                            screamer.sendCommand(command: "st")
                            isInputViewShown = false
                        }
                    }) {
                        VStack(spacing: 0)  {

                            resizableButtonImage(systemName:
                                                    "stop.circle.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("Stop voice" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif
                    }
                    .buttonStyle(MyButtonStyle())

#if !os(tvOS)
                    Button(action: {
                        withAnimation {
                            logD("open Webview")

                            windowManager.addWindow(windowType: .webView, frame: defSize, zIndex: 0, url: settingsViewModel.defaultURL)
                        }
                    }) {
                        VStack(spacing: 0)  {
                            resizableButtonImage(systemName:
                                                    "network",
                                                 size: geometry.size)
                            .cornerRadius(8)
                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("Webview" )
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)

                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)
                        .background(settingsViewModel.buttonColor)
#endif

                    }
                    .buttonStyle(MyButtonStyle())

#endif

                    Button(action: {
                        DispatchQueue.main.async {
                            settingsViewModel.latestWindowManager = windowManager

                            settingsViewModel.createAndOpenNewConvo()

                            playSelect()
                            isInputViewShown = false
                        }
                    }) {
                        VStack(spacing: 0)  {
                            resizableButtonImage(systemName:
                                                    "text.bubble.fill",
                                                 size: geometry.size)
                            .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
                            .lineLimit(1)
                            .font(.caption)

                            .foregroundColor(settingsViewModel.appTextColor)

                            Text("New chat" )
                                .lineLimit(1)
                                .minimumScaleFactor(0.01)
                                .font(.caption)
                                .foregroundColor(settingsViewModel.appTextColor)
                        }
#if !os(xrOS)

                        .background(settingsViewModel.buttonColor)
#endif

                    }
                    .buttonStyle(MyButtonStyle())

                }
                .padding()
            }
        }
    }


    struct ViewHeightKey: PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
    private func resizableButtonImage(systemName: String, size: CGSize) -> some View {
#if os(macOS) || os(tvOS)
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: size.width * 0.5 * settingsViewModel.buttonScale, height: 100 * settingsViewModel.buttonScale)
        // .background(settingsViewModel.buttonColor)

#else
            return Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: max(30, size.width / 12), height: 32.666 )
                .tint(settingsViewModel.appTextColor)
#if targetEnvironment(macCatalyst)

             .background(settingsViewModel.buttonColor)
        #endif
#endif
    }
}
struct CustomFontSize: ViewModifier {
    @Binding var size: Double

    func body(content: Content) -> some View {
        content
            .font(.system(size: CGFloat(size)))
    }
}
//final class DocumentPicker: NSObject, UIViewControllerRepresentable {
//    typealias UIViewControllerType = UIDocumentPickerViewController
//    
//    lazy var viewController:UIDocumentPickerViewController = {
//        // For picked only folder
//        let vc = UIDocumentPickerViewController(documentTypes: ["public.folder"], in: .open)
//        // For picked every document
//        //        let vc = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .open)
//        // For picked only images
//        //        let vc = UIDocumentPickerViewController(documentTypes: ["public.image"], in: .open)
//        vc.allowsMultipleSelection = false
//        //        vc.accessibilityElements = [kFolderActionCode]
//        //        vc.shouldShowFileExtensions = true
//        vc.delegate = self
//        return vc
//    }()
//    
//    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
//        viewController.delegate = self
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPicker>) {
//    }
//}
//
//extension DocumentPicker: UIDocumentPickerDelegate {
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        print("\nThe url is: \(urls)")
//
//
//        Backend.doBackend(path: urls.first?.path() ?? "")
//
//    }
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        controller.dismiss(animated: true) {
//        }
//        print("cancelled")
//    }
//}
//struct DocPickerViewController: UIViewControllerRepresentable {
//
//private let docTypes: [String] = ["com.adobe.pdf", "public.text", "public.composite-content"]
//var callback: (URL) -> ()
//private let onDismiss: () -> Void
//
//init(callback: @escaping (URL) -> (), onDismiss: @escaping () -> Void) {
//    self.callback = callback
//    self.onDismiss = onDismiss
//}
//
//func makeCoordinator() -> Coordinator { Coordinator(self) }
//
//func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerViewController>) {
//}
//
//func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
//    let controller = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
//    controller.allowsMultipleSelection = false
//    controller.delegate = context.coordinator
//    return controller
//}
//
//class Coordinator: NSObject, UIDocumentPickerDelegate {
//    var parent: DocPickerViewController
//    init(_ pickerController: DocPickerViewController) {
//        self.parent = pickerController
//    }
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        parent.callback(urls[0])
//        parent.onDismiss()
//    }
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        parent.onDismiss()
//    }
//}
//}
