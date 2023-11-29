//
//  SyntaxTextView+NonMacOS.swift
//  LogicSage
//
//  Created by Chris Dillard on 6/29/23.
//

import Foundation

#if canImport(SwiftUI)
import SwiftUI
#endif

#if !os(macOS)

// BEGIN NON-MAC VERSION OF SYNTAX TEXT VIEW
@IBDesignable
open class SyntaxTextView: UIView {

    var previousSelectedRange: NSRange?

    private var textViewSelectedRangeObserver: NSKeyValueObservation?

    let textView: InnerTextView

    public var contentTextView: TextViewUIKit {
        return textView
    }

    public weak var delegate: SyntaxTextViewDelegate? {
        didSet {
            refreshColors()
        }
    }
    var isEditing = false

    var ignoreSelectionChange = false


#if os(iOS) || os(visionOS) || os(tvOS)

    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            textView.contentInset = contentInset
            textView.scrollIndicatorInsets = contentInset
        }
    }

    open override var tintColor: UIColor! {
        didSet {

        }
    }

#else

    public var tintColor: NSColor! {
        set {
            textView.tintColor = newValue
        }
        get {
            return textView.tintColor
        }
    }

#endif
    //    @objc func doneBtnFromKeyboardClicked (sender: Any) {
    //         print("Done Button Clicked.")
    //        //Hide Keyboard by endEditing or Anything you want.
    //        self.textView.endEditing(true)
    //    }

    public override init(frame: CGRect) {
        textView = SyntaxTextView.createInnerTextView()
//        if #available(iOS 17.0, *) {
//            textView.layer.wantsExtendedDynamicRangeContent = true
//        } else {
//            // Fallback on earlier versions
//        }
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        textView = SyntaxTextView.createInnerTextView()
//        if #available(iOS 17.0, *) {
//            textView.layer.wantsExtendedDynamicRangeContent = true
//        } else {
//            // Fallback on earlier versions
//        }
#if !os(visionOS)

        textView.keyboardDismissMode = .interactive
#endif
        super.init(coder: aDecoder)
        setup()
    }

    private static func createInnerTextView() -> InnerTextView {
        let textStorage = NSTextStorage()
        let layoutManager = SyntaxTextViewLayoutManager()
#if os(macOS)
        let containerSize = CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
#endif

#if os(iOS) || os(visionOS) || os(tvOS)
        let containerSize = CGSize(width: 0, height: 0)
#endif

        let textContainer = NSTextContainer(size: containerSize)

        textContainer.widthTracksTextView = true

#if os(iOS) || os(visionOS)
        textContainer.heightTracksTextView = true
#endif
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        return InnerTextView(frame: .zero, textContainer: textContainer)
    }

#if os(macOS)
    public let scrollView = NSScrollView()
#endif

    private func setup() {

        textView.gutterWidth = 20

#if os(iOS) || os(visionOS)
        textView.translatesAutoresizingMaskIntoConstraints = false
#endif

#if  os(visionOS)
        textView.layer.wantsDynamicContentScaling = true
#endif

        self.addSubview(textView)
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true

        self.contentMode = .redraw
        textView.contentMode = .topLeft

        textViewSelectedRangeObserver = contentTextView.observe(\UITextView.selectedTextRange) { [weak self] (textView, value) in

            if let `self` = self {
                self.delegate?.didChangeSelectedRange(self, selectedRange: self.contentTextView.selectedRange)
            }

        }
        textView.innerDelegate = self
        textView.delegate = self

        textView.text = ""

#if os(iOS) || os(visionOS)

        textView.autocapitalizationType = .none
        textView.keyboardType = .default
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        if #available(iOS 11.0, *) {
            textView.smartQuotesType = .no
            textView.smartInsertDeleteType = .no
        }

        self.clipsToBounds = true

#endif

    }

#if os(macOS)

    open override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

    }

    @objc func didScroll(_ notification: Notification) {

        wrapperView.setNeedsDisplay(wrapperView.bounds)

    }

#endif

    // MARK: -

#if os(iOS) || os(visionOS)

    open override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    override open var isFirstResponder: Bool {
        return textView.isFirstResponder
    }

#endif

    @IBInspectable
    public var text: String {
        get {
#if os(macOS)
            return textView.string
#else
            return textView.text ?? ""
#endif
        }
        set {
#if os(macOS)
            textView.layer?.isOpaque = true
            textView.string = newValue
            refreshColors()
#else
            // If the user sets this property as soon as they create the view, we get a strange UIKit bug where the text often misses a final line in some Dynamic Type configurations. The text isn't actually missing: if you background the app then foreground it the text reappears just fine, so there's some sort of drawing sync problem. A simple fix for this is to give UIKit a tiny bit of time to create all its data before we trigger the update, so we push the updating work to the runloop.
//            DispatchQueue.main.async {
                self.textView.text = newValue
                self.textView.setNeedsDisplay()
                self.refreshColors()
  //          }
#endif

        }
    }

    // MARK: -

    public func insertText(_ text: String) {
        if shouldChangeText(insertingText: text) {
#if os(macOS)
            contentTextView.insertText(text, replacementRange: contentTextView.selectedRange())
#else
            contentTextView.insertText(text)
#endif
        }
    }

#if os(iOS) || os(visionOS)

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.textView.setNeedsDisplay()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        self.textView.invalidateCachedParagraphs()
        self.textView.setNeedsDisplay()
    }

#endif

    public var theme: SyntaxColorTheme? {
        didSet {
            guard let theme = theme else {
                return
            }

            cachedThemeInfo = nil
#if os(iOS) || os(visionOS)
            backgroundColor = theme.backgroundColor
#endif
            textView.backgroundColor = theme.backgroundColor
            textView.theme = theme
            textView.font = theme.font

            refreshColors()
        }
    }

    var cachedThemeInfo: ThemeInfo?

    var themeInfo: ThemeInfo? {
        if let cached = cachedThemeInfo {
            return cached
        }

        guard let theme = theme else {
            return nil
        }

        let spaceAttrString = NSAttributedString(string: " ", attributes: [.font: theme.font])
        let spaceWidth = spaceAttrString.size().width

        let info = ThemeInfo(theme: theme, spaceWidth: spaceWidth)

        cachedThemeInfo = info

        return info
    }

    var cachedTokens: [CachedToken]?

    func invalidateCachedTokens() {
        cachedTokens = nil
    }

    func colorTextView(lexerForSource: (String) -> Lexer) {
        guard let source = textView.text else {
            return
        }

        let textStorage: NSTextStorage

#if os(macOS)
        textStorage = textView.textStorage!
#else
        textStorage = textView.textStorage
#endif

        //        self.backgroundColor = theme.backgroundColor

        let tokens: [Token]

        if let cachedTokens = cachedTokens {
            updateAttributes(textStorage: textStorage, cachedTokens: cachedTokens, source: source)
        } else {
            guard let theme = self.theme else {
                return
            }

            guard let themeInfo = self.themeInfo else {
                return
            }
#if !os(macOS)

            textView.font = theme.font
#endif
            let lexer = lexerForSource(source)
            tokens = lexer.getSavannaTokens(input: source)

            let cachedTokens: [CachedToken] = tokens.map {

                let nsRange = source.nsRange(fromRange: $0.range)
                return CachedToken(token: $0, nsRange: nsRange)
            }

            self.cachedTokens = cachedTokens

            createAttributes(theme: theme, themeInfo: themeInfo, textStorage: textStorage, cachedTokens: cachedTokens, source: source)
        }
    }

    func updateAttributes(textStorage: NSTextStorage, cachedTokens: [CachedToken], source: String) {

        let selectedRange = textView.selectedRange

        let fullRange = NSRange(location: 0, length: (source as NSString).length)

        var rangesToUpdate = [(NSRange, EditorPlaceholderState)]()

        textStorage.enumerateAttribute(.editorPlaceholder, in: fullRange, options: []) { (value, range, stop) in

            if let state = value as? EditorPlaceholderState {

                var newState: EditorPlaceholderState = .inactive

                if isEditorPlaceholderSelected(selectedRange: selectedRange, tokenRange: range) {
                    newState = .active
                }

                if newState != state {
                    rangesToUpdate.append((range, newState))
                }

            }

        }

        var didBeginEditing = false

        if !rangesToUpdate.isEmpty {
            textStorage.beginEditing()
            didBeginEditing = true
        }

        for (range, state) in rangesToUpdate {

            var attr = [NSAttributedString.Key: Any]()
            attr[.editorPlaceholder] = state

            textStorage.addAttributes(attr, range: range)

        }

        if didBeginEditing {
            textStorage.endEditing()
        }
    }

    func createAttributes(theme: SyntaxColorTheme, themeInfo: ThemeInfo, textStorage: NSTextStorage, cachedTokens: [CachedToken], source: String) {

        textStorage.beginEditing()

        var attributes = [NSAttributedString.Key: Any]()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 2.0
        paragraphStyle.defaultTabInterval = themeInfo.spaceWidth * 4
        paragraphStyle.tabStops = []

        let wholeRange = NSRange(location: 0, length: (source as NSString).length)

        attributes[.paragraphStyle] = paragraphStyle

        for (attr, value) in theme.globalAttributes() {
            attributes[attr] = value
        }

        textStorage.setAttributes(attributes, range: wholeRange)

        let selectedRange = textView.selectedRange

        for cachedToken in cachedTokens {

            let token = cachedToken.token

            if token.isPlain {
                continue
            }

            let range = cachedToken.nsRange

            if token.isEditorPlaceholder {

                let startRange = NSRange(location: range.lowerBound, length: 2)
                let endRange = NSRange(location: range.upperBound - 2, length: 2)

                let contentRange = NSRange(location: range.lowerBound + 2, length: range.length - 4)

                var attr = [NSAttributedString.Key: Any]()

                var state: EditorPlaceholderState = .inactive

                if isEditorPlaceholderSelected(selectedRange: selectedRange, tokenRange: range) {
                    state = .active
                }

                attr[.editorPlaceholder] = state

                textStorage.addAttributes(theme.attributes(for: token), range: contentRange)

                textStorage.addAttributes([.foregroundColor: Colorv.clear, .font: Fontv.systemFont(ofSize: 0.01)], range: startRange)
                textStorage.addAttributes([.foregroundColor: Colorv.clear, .font: Fontv.systemFont(ofSize: 0.01)], range: endRange)

                textStorage.addAttributes(attr, range: range)
                continue
            }
            textStorage.addAttributes(theme.attributes(for: token), range: range)
        }
        textStorage.endEditing()
    }
}
#endif
// END NON-MAC VERSION OF SYNTAX TEXT VIEW
