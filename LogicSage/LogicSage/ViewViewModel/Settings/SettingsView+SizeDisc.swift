//
//  SettingsView+SizeDisc.swift
//  LogicSage
//
//  Created by Chris Dillard on 7/12/23.
//

import SwiftUI
extension SettingsView {
    func sizeSlidersDisc() -> some View {
#if os(tvOS)
        VStack { }
#else
        // START SIZE SLIDERS DISCLOSURE GROUP
        DisclosureGroup(isExpanded: $sizeSettingsExpanded)  {
            HStack {
                Text("Small")
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Slider(value: $settingsViewModel.fontSizeSrcEditor, in: fontSizeSrcEditorRange) //step: fontSizeSrceditorSteps)
                    .accentColor(settingsViewModel.buttonColor)
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Text("Large")
                    .foregroundColor(settingsViewModel.appTextColor)
                
            }
            .padding(.top,30)

            HStack {
                Text("Text")
                    .fontWeight(.semibold)
                    .foregroundColor(settingsViewModel.appTextColor)
                Text("\(settingsViewModel.fontSizeSrcEditor)")
                    .foregroundColor(settingsViewModel.appTextColor)
                    .lineLimit(nil)
            }
#if !os(xrOS)
            HStack {
                Text("Small")
                    .foregroundColor(settingsViewModel.appTextColor)
                Slider(value: $settingsViewModel.buttonScale, in:  buttonScaleRange) //step: buttonScaleSteps)
                    .accentColor(settingsViewModel.buttonColor)
                    .foregroundColor(settingsViewModel.appTextColor)
                Text("Large")
                    .foregroundColor(settingsViewModel.appTextColor)
            }
            HStack {
                Text("Buttons")
                    .fontWeight(.semibold)
                    .foregroundColor(settingsViewModel.appTextColor)
                Text("\(settingsViewModel.buttonScale)")
                    .foregroundColor(settingsViewModel.appTextColor)
                    .lineLimit(nil)
            }
#endif
            HStack {
                Text("Small")
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Slider(value: $settingsViewModel.commandButtonFontSize, in: commandButtonRange) // step: commandButtonSteps)
                    .accentColor(settingsViewModel.buttonColor)
                    .foregroundColor(settingsViewModel.appTextColor)
                Text("Large")
                    .foregroundColor(settingsViewModel.appTextColor)
            }
            HStack {
                Text("Cmd buttons")
                    .fontWeight(.semibold)
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Text("\(settingsViewModel.commandButtonFontSize)")
                    .foregroundColor(settingsViewModel.appTextColor)
                    .lineLimit(nil)
            }
            
            HStack {
                Text("Small")
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Slider(value: $settingsViewModel.cornerHandleSize, in:  cornerHandleRange) //step: cornerHandleSteps)
                    .accentColor(settingsViewModel.buttonColor)
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Text("Large")
                    .foregroundColor(settingsViewModel.appTextColor)
            }
            HStack {
                Text("Window Header")
                    .fontWeight(.semibold)
                    .foregroundColor(settingsViewModel.appTextColor)
                
                Text("\(settingsViewModel.cornerHandleSize)")
                    .foregroundColor(settingsViewModel.appTextColor)
                    .lineLimit(nil)
            }
        }
    label: { Text(sizesSettingsTitleLabelString)
            .onTapGesture {
                withAnimation {
                    sizeSettingsExpanded.toggle()
                }
            }
    }
    .onChange(of: sizeSettingsExpanded) { isExpanded in
        sizesSettingsTitleLabelString = "\(isExpanded ? "🔽" : "▶️") Size settings"
        playSelect()
        
    }
    .padding(.leading, 8)
    .padding(.trailing, 8)
    .foregroundColor(settingsViewModel.appTextColor)

#endif
    }
}
