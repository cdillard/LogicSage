//
//  SyntaxTheme.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation
import CoreGraphics

public struct LineNumbersStyle {
	
	public let font: Font
	public let textColor: Colorv
	
	public init(font: Font, textColor: Colorv) {
		self.font = font
		self.textColor = textColor
	}

}

public struct GutterStyle {

	public let backgroundColor: Colorv

	/// If line numbers are displayed, the gutter width adapts to fit all line numbers.
	/// This specifies the minimum width that the gutter should have at all times,
	/// regardless of any line numbers.
	public let minimumWidth: CGFloat
	
	public init(backgroundColor: Colorv, minimumWidth: CGFloat) {
		self.backgroundColor = backgroundColor
		self.minimumWidth = minimumWidth
	}
}

public protocol SyntaxColorTheme {
	
	/// Nil hides line numbers.
	var lineNumbersStyle: LineNumbersStyle? { get }
	
	var gutterStyle: GutterStyle { get }
	
	var font: Font { get }
	
	var backgroundColor: Colorv { get }

	func globalAttributes() -> [NSAttributedString.Key: Any]

	func attributes(for token: Token) -> [NSAttributedString.Key: Any]
}
