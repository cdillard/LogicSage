//
//  SettingsView+ColorDisc.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/11/23.
//

import SwiftUI
extension SettingsView {
    func colorDisc(size: CGSize) -> some View {
#if os(tvOS)
        VStack { }
#else
        // START OF COLOR SETTINGS DISCLOSURE GROUP
        
        DisclosureGroup(isExpanded: $colorSettingsExpanded) {
            // TERMINAL COLORS SETTINGS ZONE
            Group {
                Group {
                    
                    HStack {
                        Text("Themes:").font(.body)
                        
                        Text("Deep Space Sparkle")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .font(.body)
                            .padding()
                            .onTapGesture {
                                logD("Tapped Deep Space Sparkle theme")
                                settingsViewModel.applyTheme(theme: .deepSpace)
                            }
                        Text("Hackeresque")
                            .foregroundColor(settingsViewModel.appTextColor)
                            .font(.body)
                            .padding()
                            .onTapGesture {
                                logD("Tapped Hackeresque theme")
                                settingsViewModel.applyTheme(theme: .hacker)
                            }
                    }
                }
                Group {
                    VStack( spacing: 3) {
                        
                        ColorPicker("App Text Color", selection:
                                        $settingsViewModel.appTextColor)
                        .frame(width: size.width / 2, alignment: .leading)
                        .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack( spacing: 3) {
                        
                        ColorPicker("App Button Color", selection:
                                        $settingsViewModel.buttonColor)
                        .frame(width: size.width / 2, alignment: .leading)
                        .foregroundColor(settingsViewModel.appTextColor)
                    }
                    
                    VStack( spacing: 3) {
                        
                        ColorPicker("App Background Color", selection:
                                        $settingsViewModel.backgroundColor)
                        .frame(width: size.width / 2, alignment: .leading)
                        .foregroundColor(settingsViewModel.appTextColor)
                    }
                }
            }
            moreColorDisc(size: size)
                .font(.title3)
            
        }
    label: { Text(colorSettingsTitleLabelString)
            .onTapGesture {
                withAnimation {
                    colorSettingsExpanded.toggle()
                }
            }}
    .onChange(of: colorSettingsExpanded) { isExpanded in
        colorSettingsTitleLabelString  = "\(isExpanded ? "🔽" : "▶️") Color settings"
        playSelect()
        
    }
#endif
    }
    func moreColorDisc(size: CGSize) -> some View {
#if os(tvOS)
        VStack { }
#else
        DisclosureGroup(isExpanded: $moreColorSettingsExpanded) {
            Group {
                Group {
                    VStack(spacing: 3) {
                        ColorPicker("Plain text", selection: $settingsViewModel.plainColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack(spacing: 3) {
                        ColorPicker("Number", selection: $settingsViewModel.numberColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                        
                    }
                    VStack(spacing: 3) {
                        ColorPicker("String", selection: $settingsViewModel.stringColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                }
                Group {
                    VStack(spacing: 3) {
                        ColorPicker("Identifier", selection: $settingsViewModel.identifierColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack(spacing: 3) {
                        ColorPicker("Keyword", selection: $settingsViewModel.keywordColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack(spacing: 3) {
                        ColorPicker("Comment", selection: $settingsViewModel.commentColorSrceEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                }
                Group {
                    VStack(spacing: 3) {
                        ColorPicker("Placeholder", selection: $settingsViewModel.editorPlaceholderColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack(spacing: 3) {
                        ColorPicker("Background", selection: $settingsViewModel.backgroundColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                    VStack(spacing: 3) {
                        ColorPicker("Line number", selection: $settingsViewModel.lineNumbersColorSrcEditor)
                            .frame(width: size.width / 2, alignment: .leading)
                            .foregroundColor(settingsViewModel.appTextColor)
                    }
                }
            }
        }
    label: { Text(moreColorSettingsTitleLabelString)
            .onTapGesture {
                withAnimation {
                    moreColorSettingsExpanded.toggle()
                }
            }
    }
    .onChange(of: moreColorSettingsExpanded) { isExpanded in
        moreColorSettingsTitleLabelString  = "\(isExpanded ? "🔽" : "▶️") Code/Chat color settings"
        playSelect()
        
    }
    .padding(.leading, 8)
    .padding(.trailing, 8)
    .accentColor(settingsViewModel.buttonColor)
    .foregroundColor(settingsViewModel.appTextColor)
#endif
    }
}
