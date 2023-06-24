//
//  Types.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//

import Foundation

#if os(macOS)
	
	import AppKit
	
public typealias _Viewv            = NSView
public typealias ViewControllerv = NSViewController
public typealias Windowv            = NSWindow
public typealias Controlv        = NSControl
public typealias TextViewv        = NSTextView
public typealias TextFieldv        = NSTextField
public typealias Buttonv    = NSButton
public typealias Fontv            = NSFont
public typealias Colorv            = NSColor
public typealias StackViewv        = NSStackView
public typealias Imagev            = NSImage
public typealias BezierPath        = NSBezierPath
public typealias ScrollViewv    = NSScrollView
public typealias Screenv            = NSScreen

#elseif os(xrOS)

#else

import UIKit

public typealias Viewv            = UIView
public typealias ViewController = UIViewController
public typealias Window            = UIWindow
public typealias Control        = UIControl
public typealias TextViewUIKit        = UITextView
public typealias TextFieldUIKit        = UITextField
public typealias Buttonv            = UIButton
public typealias Fontv            = UIFont
public typealias Colorv            = UIColor
public typealias StackView        = UIStackView
public typealias Imagev            = UIImage
public typealias BezierPath        = UIBezierPath
public typealias ScrollViewv    = UIScrollView
public typealias Screen            = UIScreen
#endif

