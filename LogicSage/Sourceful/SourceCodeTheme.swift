//
//  SourceCodeTheme.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation

public protocol SourceCodeTheme: SyntaxColorTheme {
	
	func color(for syntaxColorType: SourceCodeTokenType) -> Colorv
	
}

extension SourceCodeTheme {
	
	public func globalAttributes() -> [NSAttributedString.Key: Any] {
		
		var attributes = [NSAttributedString.Key: Any]()

        #if !os(macOS)
		attributes[.font] = font
        #endif
        attributes[.foregroundColor] = color(for: .plain)
		
		return attributes
	}
	
	public func attributes(for token: Token) -> [NSAttributedString.Key: Any] {
		var attributes = [NSAttributedString.Key: Any]()
		
		if let token = token as? SimpleSourceCodeToken {
			attributes[.foregroundColor] = color(for: token.type)
		}
		
		return attributes
	}
	
}
