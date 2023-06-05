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

#if os(iOS)

public typealias _ViewRepresentable = UIViewRepresentable

#endif
#if !os(macOS)


public struct SourceCodeTextEditor: _ViewRepresentable {
    
    public struct Customization {
        var didChangeText: (SourceCodeTextEditor) -> Void
        var insertionPointColor: () -> Colorv
        var lexerForSource: (String) -> Lexer
        var textViewDidBeginEditing: (SourceCodeTextEditor) -> Void
        var theme: () -> SourceCodeTheme
        var overrideText: () -> String?

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
            overrideText: @escaping () -> String?

        ) {
            self.didChangeText = didChangeText
            self.insertionPointColor = insertionPointColor
            self.lexerForSource = lexerForSource
            self.textViewDidBeginEditing = textViewDidBeginEditing
            self.theme = theme
            self.overrideText = overrideText
        }
    }
    
    @Binding var text: String
    @Binding private var isEditing: Bool
    @Binding private var isLocktoBottom: Bool

    private var shouldBecomeFirstResponder: Bool
    private var custom: Customization
    
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
            overrideText: { nil }
        ),
        shouldBecomeFirstResponder: Bool = false
    ) {
        self._text = text
        self._isEditing = isEditing
        self._isLocktoBottom = isLockToBottom
        self.custom = customization
        self.shouldBecomeFirstResponder = shouldBecomeFirstResponder
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    #if os(iOS)
    public func makeUIView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
//        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateUIView(_ view: SyntaxTextView, context: Context) {
        if shouldBecomeFirstResponder {
            _ = view.becomeFirstResponder()
        }

        let overrideText = custom.overrideText()

        DispatchQueue.main.async {

            view.textView.isEditable = isEditing

            view.contentTextView.isEditable = isEditing


            view.isEditing = isEditing
            view.textView.isSelectable = isEditing
            view.contentTextView.isSelectable = isEditing
            if let overrideText = overrideText {


                context.coordinator.wrappedView.text = overrideText

                if isLocktoBottom {
                    let location = view.textView.text.count - 1
                    let bottom = NSMakeRange(location, 1)
                    view.textView.scrollRangeToVisible(bottom)
                }
            }
        }
    }
    #endif
    
    #if os(macOS)
    public func makeNSView(context: Context) -> SyntaxTextView {
        let wrappedView = SyntaxTextView()
        wrappedView.delegate = context.coordinator
        wrappedView.theme = custom.theme()
        wrappedView.contentTextView.insertionPointColor = custom.insertionPointColor()
        
        context.coordinator.wrappedView = wrappedView
        context.coordinator.wrappedView.text = text
        
        return wrappedView
    }
    
    public func updateNSView(_ view: SyntaxTextView, context: Context) {
        view.text = text
    }
    #endif
    

}

extension SourceCodeTextEditor {
    
    public class Coordinator: SyntaxTextViewDelegate {
        let parent: SourceCodeTextEditor
        var wrappedView: SyntaxTextView!
        
        init(_ parent: SourceCodeTextEditor) {
            self.parent = parent
        }
        
        public func lexerForSource(_ source: String) -> Lexer {
            parent.custom.lexerForSource(source)
        }
        
        public func didChangeText(_ syntaxTextView: SyntaxTextView) {
            let myNewText = syntaxTextView.text
//            DispatchQueue.main.async {
//            }
            self.parent.text = myNewText

            // allow the client to decide on thread
            parent.custom.didChangeText(parent)
        }
        
        public func textViewDidBeginEditing(_ syntaxTextView: SyntaxTextView) {
            parent.custom.textViewDidBeginEditing(parent)
        }
    }
}
#endif
#endif
