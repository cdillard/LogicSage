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
#if os(iOS) || os(xrOS)
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
            codeDidCopy: @escaping () -> Void

        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
            self.overrideText = overrideText
            self.codeDidCopy = codeDidCopy
        }
    }
    
    @Binding var text: String
    @Binding private var isEditing: Bool
    @Binding private var isLocktoBottom: Bool
    private var shouldBecomeFirstResponder: Bool
    private var custom: Customization
    @Binding private var isMoveGestureActive: Bool
    @Binding private var isResizeGestureActive: Bool
    
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
            codeDidCopy: { }
        ),
        shouldBecomeFirstResponder: Bool = false,
        isMoveGestureActive: Binding<Bool>,
        isResizeGestureActive: Binding<Bool>
    ) {
        self._text = text
        self._isEditing = isEditing
        self._isLocktoBottom = isLockToBottom
        self.custom = customization
        self.shouldBecomeFirstResponder = shouldBecomeFirstResponder
        self._isMoveGestureActive = isMoveGestureActive
        self._isResizeGestureActive = isResizeGestureActive
    }
    public func makeCoordinator() -> Coordinator {
        Coordinator(self,text: $text, isLockToBottom: $isLocktoBottom)
    }
    
#if !os(macOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        wrappedView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        return wrappedView
    }
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
        if shouldBecomeFirstResponder {
            _ = view.becomeFirstResponder()
        }

        let overrideText = custom.overrideText()
        view.textView.isEditable = isEditing
        view.contentTextView.isEditable = isEditing
        view.isEditing = isEditing
        view.textView.isSelectable = isEditing
        view.contentTextView.isSelectable = isEditing
        if let overrideText = overrideText {
            if overrideText != context.coordinator.wrappedView.text && isLocktoBottom {
                context.coordinator.wrappedView.text = overrideText
                context.coordinator.textDidChange()
            }
        }
    }
#endif
}
extension SourceCodeTextEditor {
    public class Coordinator: SyntaxTextViewDelegate {
        let parent: SourceCodeTextEditor
        var wrappedView: SyntaxTextView!
        @Binding var boundText: String
        @Binding var isLockToBottom: Bool

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
            if isLockToBottom {
                let textView = wrappedView.textView
#if !os(macOS)
                textView.scrollRangeToVisible(NSMakeRange(textView.text.count - 1, 1))
#endif
                //print("scrolling chatview to bottom")
            }
            else {
               // print("isLockToBottom false -- not scrolling")
            }
        }
    }
}
#endif
#endif
