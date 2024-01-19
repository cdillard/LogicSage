//
//  SourceCodeTextEditor.swift
//
//  Created by Andrew Eades on 14/08/2020.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#if os(macOS)
public typealias _ViewRepresentable = NSViewRepresentable
#endif
#if os(iOS) || os(visionOS)
public typealias _ViewRepresentable = UIViewRepresentable
#endif
#if !os(tvOS)

public struct SourceCodeTextEditor: _ViewRepresentable {

#if os(macOS)
    public func makeNSView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        return wrappedView
    }
    public func updateNSView(_ view: SyntaxTextView, context: Context) {
        view.text = text
    }
#endif

    public struct Customization {
        var didChangeText: (SourceCodeTextEditor) -> Void
        var insertionPointColor: () -> Colorv
        var lexerForSource: (String) -> Lexer
        var textViewDidBeginEditing: (SourceCodeTextEditor) -> Void
        var theme: () -> SourceCodeTheme
        var overrideText: () -> String?
        var codeDidCopy: () -> Void
        var windowType: () -> WindowInfo.WindowType

        /// Creates a **Customization** to pass into the *init()* of a **SourceCodeTextEditor**.
        ///
        /// - Parameters:
        ///     - didChangeText: A SyntaxTextView delegate action.
        ///     - lexerForSource: The lexer to use (default: SwiftLexer()).
        ///     - insertionPointColor: To customize color of insertion point caret (default: .white).
        ///     - textViewDidBeginEditing: A SyntaxTextView delegate action.
        ///     - theme: Custom theme (default: DefaultSourceCodeTheme()).
        public init(
            didChangeText: @escaping (SourceCodeTextEditor) -> Void,
            insertionPointColor: @escaping () -> Colorv,
            lexerForSource: @escaping (String) -> Lexer,
            textViewDidBeginEditing: @escaping (SourceCodeTextEditor) -> Void,
            theme: @escaping () -> SourceCodeTheme,
            overrideText: @escaping () -> String?,
            codeDidCopy: @escaping () -> Void,
            windowType: @escaping () -> WindowInfo.WindowType


        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
            self.overrideText = overrideText
            self.codeDidCopy = codeDidCopy
            self.windowType = windowType

        }
    }
    @EnvironmentObject var appModel: AppModel
    @ObservedObject private var eventManager = GlobalEventManager.shared
    @Binding var text: String
    @Binding private var isEditing: Bool
    @Binding private var isLocktoBottom: Bool
    private var shouldBecomeFirstResponder: Bool
    private var custom: Customization
    @Binding private var isMoveGestureActive: Bool
    @Binding private var isResizeGestureActive: Bool
    @Binding private var convoId: String

    @State  var lastScreenshot = Date()
    @State  var lastScroll = Date()

    @State var lastSize = CGSizeZero

    public init(
        text: Binding<String>,
        isEditing: Binding<Bool>,
        isLockToBottom: Binding<Bool>,
        customization: Customization = Customization(
            didChangeText: {_ in },
            insertionPointColor: { Colorv.white },
            lexerForSource: { _ in SwiftLexer() },
            textViewDidBeginEditing: { _ in },
            theme: { DefaultSourceCodeTheme(settingsViewModel: SettingsViewModel.shared) },
            overrideText: { nil },
            codeDidCopy: { },
            windowType: { .file }
        ),
        shouldBecomeFirstResponder: Bool = false,
        isMoveGestureActive: Binding<Bool>,
        isResizeGestureActive: Binding<Bool>,
        convoId: Binding<String>

    ) {
        self._text = text
        self._isEditing = isEditing
        self._isLocktoBottom = isLockToBottom
        self.custom = customization
        self.shouldBecomeFirstResponder = shouldBecomeFirstResponder
        self._isMoveGestureActive = isMoveGestureActive
        self._isResizeGestureActive = isResizeGestureActive
        self._convoId = convoId

    }
    public func makeCoordinator() -> Coordinator {
        Coordinator(self,text: $text, isLockToBottom: $isLocktoBottom)
    }

#if !os(macOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator

        wrappedView.textView.delegate = context.coordinator

        wrappedView.theme = custom.theme()
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        wrappedView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        if SettingsViewModel.shared.projectedConvoId == convoId {
            updateTexture(view: wrappedView)
        }

        return wrappedView
    }
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
        if shouldBecomeFirstResponder {
            _ = view.becomeFirstResponder()
        }

        let overrideText = custom.overrideText()
        let type = custom.windowType()
        Task {
            await MainActor.run {

                view.textView.isEditable = type == .file
                view.contentTextView.isEditable = type == .file
                view.isEditing = type == .file
                view.textView.isSelectable = type == .file || type == .chat
                view.contentTextView.isSelectable = type == .file || type == .chat
            }
        }
        if let overrideText = overrideText {
            if overrideText != context.coordinator.wrappedView.text && isLocktoBottom {
                context.coordinator.wrappedView.text = overrideText
                context.coordinator.textDidChange()

                if SettingsViewModel.shared.projectedConvoId == convoId {

                    //updateTexture(view: view)
                    Task {
                        await MainActor.run {
                            eventManager.frameUpdate = true
                        }
                    }
                }
            }
        }

        // If content Size changes from one update to the next
        //updateTexture(view: view)
        if SettingsViewModel.shared.projectedConvoId == convoId {

            Task {
                await MainActor.run {
                    if view.frame.size != lastSize {

                        eventManager.frameUpdate = true

                        lastSize = view.frame.size
                    }
                }

            }


            if eventManager.frameUpdate {
                updateTexture(view: view)
                Task {
                    await MainActor.run {
                        eventManager.frameUpdate = false
                    }
                }
            }

        }
    }

    func updateTexture(view: SyntaxTextView) {
#if os(visionOS)
        // TODO: DOUBLE CHECK WHEN TO UPDATE THIS
        if appModel.isShowingImmersiveScene || appModel.isShowingImmersiveWindow {
            if SettingsViewModel.shared.projectedConvoId == convoId {
                Task {

                    let now = Date()

                    if now.timeIntervalSince(self.lastScreenshot) >= texUpdateInteral {
                        self.lastScreenshot = now

                        var image = view.screenshot()
                        var image3 = addBorders(image: image)
                        image = nil

                        if let data = image3?.pngData() {
                            image3 = nil
                            lastTextureImageData = data
                            eventManager.eventOccurred = true
                        }
                    }
                }
            }
        }
#endif
    }
#endif
}
extension SourceCodeTextEditor {
    public class Coordinator: NSObject, SyntaxTextViewDelegate, UITextViewDelegate {
        let parent: SourceCodeTextEditor
        var wrappedView: SyntaxTextView!
        @Binding var boundText: String
        @Binding var isLockToBottom: Bool
        private var previousContentHeight: CGFloat = 0
        init(_ parent: SourceCodeTextEditor, text: Binding<String>, isLockToBottom: Binding<Bool>) {
            self.parent = parent
            _boundText = text
            _isLockToBottom = isLockToBottom
        }

        public func lexerForSource(_ source: String) -> Lexer {
            parent.custom.lexerForSource(source)
        }

        public func didChangeText(_ syntaxTextView: SyntaxTextView) {
#if !os(macOS)

            let myNewText = syntaxTextView.text
            self.parent.text = myNewText
            // allow the client to decide on thread
            parent.custom.didChangeText(parent)
#endif
        }

        public func textViewDidBeginEditing(_ syntaxTextView: SyntaxTextView) {
            parent.custom.textViewDidBeginEditing(parent)
        }

        public func codeDidCopy() {
            parent.custom.codeDidCopy()
        }

        @objc func textDidChange() {
            // IDEA 1
            if isLockToBottom {

                let now = Date()

                if now.timeIntervalSince(parent.lastScroll) >= scrollUpdateInteral {
                    Task {
                        await MainActor.run { [weak self] in
                            self?.parent.lastScroll = now

                            guard let textView = self?.wrappedView.textView else { return }
#if !os(macOS)
                            let lastLineRect = textView.layoutManager.lineFragmentRect(forGlyphAt: textView.text.count - 1, effectiveRange: nil)
                            let contentBottom = lastLineRect.origin.y + lastLineRect.size.height
                            let isContentAlreadyAtBottom = contentBottom <= textView.contentOffset.y + textView.bounds.size.height

                            // Scroll only if the content is not already at the bottom
                            if !isContentAlreadyAtBottom {
                                let range = NSMakeRange(textView.text.count - 1, 1)
                                textView.scrollRangeToVisible(range)
                            }
#endif
                            //print("scrolling chatview to bottom")
                        }
                    }
                }
            }
            else {
                // print("isLockToBottom false -- not scrolling")
            }
        }

        // This method is called whenever the scroll view (UITextView in this case) is scrolled
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            Task {
                await MainActor.run { [weak self] in
                    self?.parent.eventManager.frameUpdate = true
                }
            }
        }
    }
}
#endif
#endif
