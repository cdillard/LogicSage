//
//  InnerTextView.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

protocol InnerTextViewDelegate: AnyObject {
    func didUpdateCursorFloatingState()
    func didCopyCode()

}

#if !os(macOS)
#if !os(xrOS)

class InnerTextView: TextViewUIKit {

    weak var innerDelegate: InnerTextViewDelegate?

    var theme: SyntaxColorTheme?

    var cachedParagraphs: [Paragraph]?

    func invalidateCachedParagraphs() {
        cachedParagraphs = nil
    }

    func hideGutter() {
        gutterWidth = theme?.gutterStyle.minimumWidth ?? 0.0
    }

    func updateGutterWidth(for numberOfCharacters: Int) {

        let leftInset: CGFloat = 4.0
        let rightInset: CGFloat = 4.0

        let charWidth: CGFloat = 10.0

        gutterWidth = max(theme?.gutterStyle.minimumWidth ?? 0.0, CGFloat(numberOfCharacters) * charWidth + leftInset + rightInset)

    }

#if os(iOS)
    var isCursorFloating = false

    override func beginFloatingCursor(at point: CGPoint) {
        super.beginFloatingCursor(at: point)

        isCursorFloating = true
        innerDelegate?.didUpdateCursorFloatingState()
    }
    override func endFloatingCursor() {
        super.endFloatingCursor()

        isCursorFloating = false
        innerDelegate?.didUpdateCursorFloatingState()
    }
    struct CodeBlock {
        let range: NSRange
        let text: String
    }

    private func parseForCodeBlocks() -> [CodeBlock] {
        let text = self.attributedText.string
        let pattern = "```([^`]+)```"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))

        var codeBlocks = [CodeBlock]()
        for match in matches {
            if let range = Range(match.range, in: text) {
                let code = String(text[range])
                let codeBlock = CodeBlock(range: match.range, text: removeFirstAndLastLine(from: code))
                codeBlocks.append(codeBlock)
            }
        }
        return codeBlocks
    }
    private func removeFirstAndLastLine(from string: String) -> String {
        var lines = string.split(separator: "\n", omittingEmptySubsequences: false)
        if !lines.isEmpty { lines.removeFirst() }
        if !lines.isEmpty { lines.removeLast() }
        let remainingString = lines.joined(separator: "\n")
        return remainingString
    }
    private func calculateButtonRect(for codeBlock: CodeBlock) -> CGRect {
        // Get the bounding rectangle for the code block
        let glyphRange = layoutManager.glyphRange(forCharacterRange: codeBlock.range, actualCharacterRange: nil)
        var boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

        // Convert the bounding rectangle's origin from text container coordinates to UITextView coordinates
        boundingRect.origin.x += textContainerInset.left
        boundingRect.origin.y += textContainerInset.top

        // Calculate the position for the button
        // For example, position the button at the top-right corner of the bounding rectangle
        let buttonSize = CGSize(width: 158.6666, height: 39.666)
        let buttonOrigin = CGPoint(x: boundingRect.maxX - buttonSize.width, y: boundingRect.minY)

        return CGRect(origin: buttonOrigin, size: buttonSize)
    }
    @objc private func copyCode(_ sender: UIButton) {
        // Get the index of the button that was tapped
        let index = sender.tag

        // Get the code blocks
        let codeBlocks = parseForCodeBlocks()

        // Get the code for the tapped buttonx`
        if index < codeBlocks.count {
            let codeBlock = codeBlocks[index]
#if !os(macOS)
#if !os(xrOS)
            // Copy the code to the clipboard
            UIPasteboard.general.string = codeBlock.text
            innerDelegate?.didCopyCode()
#endif
#endif
        }
        else {
            logD("failed to copy code block outisde bound \(index)")
        }
    }
    var codeBlocks = [CodeBlock]()
    var savedButtons = [UIButton]()

    override public func draw(_ rect: CGRect) {

        guard let theme = theme else {
            super.draw(rect)
            hideGutter()
            return
        }

        let textView = self

        if theme.lineNumbersStyle == nil  {

            hideGutter()

            let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
            let path = BezierPath(rect: gutterRect)
            path.fill()

            codeBlocks = parseForCodeBlocks()
            for savedButton in savedButtons {
                savedButton.removeFromSuperview()
            }
            for (index, codeBlock) in codeBlocks.enumerated() {
                let copyCodeButtonFrame = calculateButtonRect(for: codeBlock)

                let button = UIButton(frame: copyCodeButtonFrame)
                if let image = UIImage(systemName: "doc.on.doc.fill") { // Use the appropriate system symbol name
                    button.setImage(image, for: .normal)
                    button.tintColor = UIColor(SettingsViewModel.shared.plainColorSrcEditor)
                }
                button.backgroundColor = UIColor(SettingsViewModel.shared.buttonColor)
                button.titleLabel?.textColor = UIColor(SettingsViewModel.shared.plainColorSrcEditor)
                button.titleLabel?.font = .systemFont(ofSize: SettingsViewModel.shared.fontSizeSrcEditor)
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.numberOfLines = 1
                button.setTitle( "Longpress to Copy code", for: .normal)
                button.tag = index
                button.addTarget(self, action: #selector(copyCode), for: .touchDown)
                button.layer.opacity = 0.666
                button.addInteraction(UIPointerInteraction(delegate: self))
                // Add the button to the text view
                addSubview(button)
                savedButtons.append(button)
            }

        } else {

            let components = textView.text.components(separatedBy: .newlines)

            let count = components.count

            let maxNumberOfDigits = "\(count)".count

            textView.updateGutterWidth(for: maxNumberOfDigits)

            var paragraphs: [Paragraph]

            if let cached = textView.cachedParagraphs {

                paragraphs = cached

            } else {

                paragraphs = generateParagraphs(for: textView, flipRects: false)
                textView.cachedParagraphs = paragraphs

            }

            theme.gutterStyle.backgroundColor.setFill()

            let gutterRect = CGRect(x: 0, y: rect.minY, width: textView.gutterWidth, height: rect.height)
            let path = BezierPath(rect: gutterRect)
            path.fill()

            drawLineNumbers(paragraphs, in: rect, for: self)
        }
        super.draw(rect)
    }
#endif
    var gutterWidth: CGFloat {
        set {

#if os(macOS)
            textContainerInset = NSSize(width: newValue, height: 0)
#else
            textContainerInset = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
#endif

        }
        get {

#if os(macOS)
            return textContainerInset.width
#else
            return textContainerInset.left
#endif

        }
    }

#if os(iOS)
    override func caretRect(for position: UITextPosition) -> CGRect {

        var superRect = super.caretRect(for: position)

        guard let theme = theme else {
            return superRect
        }

        let font = theme.font

        // "descender" is expressed as a negative value,
        // so to add its height you must subtract its value
        superRect.size.height = font.pointSize - font.descender

        return superRect
    }
#endif
}
#endif
#endif
