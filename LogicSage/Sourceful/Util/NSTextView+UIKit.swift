//
//  NSTextView+UIKit.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 09/07/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

#if !os(iOS)
#if !os(tvOS)
#if !os(visionOS)
import AppKit
extension NSTextView {
	
	var text: String! {
		get {
			return string
		}
		set {
			self.string = newValue
		}
	}
}
#endif
#endif
#endif
