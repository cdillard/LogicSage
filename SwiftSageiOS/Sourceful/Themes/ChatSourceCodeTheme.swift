//
//  DefaultSourceCodeTheme.swift
//  SourceEditor
//
//  Created by Louis D'hauwe on 24/07/2018.
//  Copyright © 2018 Silver Fox. All rights reserved.
//

import Foundation
#if !os(macOS)
#if !os(xrOS)

public struct ChatSourceCodeTheme: SourceCodeTheme {
    var settingsViewModel: SettingsViewModel
    public init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
	}
	
    static var lineNumbersColor: Colorv {
        Colorv(SettingsViewModel.shared.lineNumbersColorSrcEditor)
	}
	
	public let lineNumbersStyle: LineNumbersStyle? = nil//LineNumbersStyle(font: Font(name: "Menlo", size: 9)!, textColor: lineNumbersColor)
	
	public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: Colorv(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 0)
	
    public let font = getFont()

    static func getFont() -> Fontv {
        Fontv(name: "Menlo", size: CGFloat(SettingsViewModel.shared.fontSizeSrcEditor))!
    }
    public let backgroundColor = Colorv(SettingsViewModel.shared.backgroundColorSrcEditor)
	
	public func color(for syntaxColorType: SourceCodeTokenType) -> Colorv {
		
		switch syntaxColorType {
		case .plain:
            return Colorv(settingsViewModel.plainColorSrcEditor)
			
		case .number:
            return Colorv(settingsViewModel.numberColorSrcEditor)
			
		case .string:
            return Colorv(settingsViewModel.stringColorSrcEditor)
			
		case .identifier:
            return Colorv(settingsViewModel.identifierColorSrcEditor)
			
		case .keyword:
            return Colorv(settingsViewModel.keywordColorSrcEditor)
			
		case .comment:
            return Colorv(settingsViewModel.commentColorSrceEditor)
			
		case .editorPlaceholder:
            return Colorv(settingsViewModel.editorPlaceholderColorSrcEditor)

		}
		
	}
	
}
#endif
#endif
