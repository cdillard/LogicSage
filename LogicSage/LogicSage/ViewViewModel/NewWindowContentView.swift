//
//  NewWindowContentView.swift
//  LogicSage
//
//  Created by Chris Dillard on 1/23/24.
//

import Foundation
import SwiftUI
import Foundation
import Combine
import AVKit

#if os(macOS)
import AppKit
#endif

struct NewWindowContentView: View {
#if !os(tvOS)

    @Environment(\.openWindow) private var openWindow
#endif

    @ObservedObject private var eventManager = GlobalEventManager.shared

    @State private var tabSelection = 1
    @State private var showAddView = false
    @State private var showSettings = false
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @StateObject var windowManager = WindowManager()
    @State private var isInputViewShown = false
    @State var showInstructions: Bool = !hasSeenInstructions()
    @State var showHelp: Bool = false
    @State var viewSize: CGRect = .zero

    @EnvironmentObject var appModel: AppModel

#if os(visionOS)

    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
#endif

#if !os(macOS)
#if !os(visionOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
#if !os(tvOS)

    @ObservedObject var keyboardResponder = KeyboardResponder()
#endif
#endif
#endif
    @State var keyboardHeight: CGFloat = 0
    @State var dragCursorPoint: CGPoint = .zero


    //@State  var showDialog: Bool = false
    @State  var name: String = ""
    @State  var description: String = ""
    @State  var instructions: String = ""


    @State private var isModalPresented = false
    @State private var isUploading = false

    //If a file is selected via the document picker, this is set.
    @State var selectedFileURL: URL?
    @State var uploadedFileId: String?
    @State private var fileIds: [String] = []

    @State private var codeInterpreter: Bool = false
    @State private var retrieval: Bool = false

    @State private var isPickerPresented: Bool = false
    @State private var fileURL: URL?

    @State var mode: AssistantModalContentView.Mode = .create


#if !os(macOS)
    let appearance: UITabBarAppearance = UITabBarAppearance()
    init() {
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
#endif
    var body: some View {
        GeometryReader { geometry in

            ZStack {
                ForEach(windowManager.windowViewModels  ) { windowViewModel in

                    WindowView(window: windowViewModel.windowInfo, settingsViewModel: settingsViewModel, windowManager: windowManager, viewModel: windowViewModel, parentViewSize: $viewSize, keyboardHeight: $keyboardHeight, dragCursorPoint: $dragCursorPoint, noBars: Binding.constant(true))
//                        .padding(.top, 20)
                       // .padding(.bottom, 26)
                      .frame(maxWidth: .infinity, maxHeight: .infinity)

                }

//                            Button(action: {
//                                DispatchQueue.main.async {
//                                    settingsViewModel.latestWindowManager = windowManager
//                
//                                    settingsViewModel.createAndOpenNewConvo()
//                
//                                    playSelect()
//                                    isInputViewShown = false
//                                    tabSelection = 1
//                
//                                }
//                            }) {
//                                VStack(spacing: 0)  {
//                //                    resizableButtonImage(systemName:
//                //                                            "text.bubble.fill",
//                //                                         size: geometry.size)
//                //                    .modifier(CustomFontSize(size: $settingsViewModel.commandButtonFontSize))
//                //                    .lineLimit(1)
//                //                    .font(.caption)
//                
//                            //        .foregroundColor(settingsViewModel.appTextColor)
//                
//                                    Text("New chat" )
//                                        .lineLimit(1)
//                                        .minimumScaleFactor(0.01)
//                                        .font(.caption)
//                                        .foregroundColor(settingsViewModel.appTextColor)
//                                }
//                #if !os(visionOS)
//                
//                                .background(settingsViewModel.buttonColor)
//                #endif
//                
//                           }
            }
            .onAppear {
                self.settingsViewModel.windowManagers.append(windowManager)

                if let repoFile = eventManager.pendingFile, let fileContents = eventManager.pendingFileContent {
                    windowManager.addWindow(windowType: .file, frame: .zero, zIndex: 0, file: repoFile, fileContents: fileContents)
                    eventManager.pendingFile = nil
                    eventManager.pendingFileContent = nil
                }
                    else {

                        recalculateWindowSize(size: geometry.size)

                        settingsViewModel.latestWindowManager = windowManager

                        settingsViewModel.createAndOpenNewConvo()

                        playSelect()
                        isInputViewShown = false
                        tabSelection = 1
                    }

            }
#if os(visionOS)
            .onChange(of: geometry.size) {
                recalculateWindowSize(size: geometry.size)
            }
#endif
        }
    }
    private func recalculateWindowSize(size: CGSize) {
#if !os(macOS)
        if viewSize.size != size {
            if UIDevice.current.userInterfaceIdiom == .phone {
                // iOS
                defSize = CGRectMake(0, 0, size.width - (size.width * 0.1), size.height - (size.height * 0.2))
                defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.1), size.height - (size.height * 0.2))
            }
            else {
                defSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.33))
                defChatSize = CGRectMake(0, 0, size.width - (size.width * 0.32), size.height - (size.height * 0.33))
            }
            // set parentViewSize
            viewSize = CGRectMake(0, 0, size.width, size.height)
            if gestureDebugLogs {
                logD("contentView viewSize update = \(viewSize)")
            }
        }
#endif
    }
}

