//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    @ObservedObject var viewModel: SettingsViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

            VStack(alignment: .leading, spacing: 15) {
                Text("Terminal Background Color")
                    .fontWeight(.semibold)
                ColorPicker("", selection: $viewModel.terminalBackgroundColor)
                    .labelsHidden()
                    .padding(.horizontal, 8)
            }

            VStack(alignment: .leading, spacing: 15) {
                Text("Terminal Text Color")
                    .fontWeight(.semibold)
                ColorPicker("", selection: $viewModel.terminalTextColor)
                    .labelsHidden()
                    .padding(.horizontal, 8)
            }

            VStack(alignment: .leading, spacing: 15) {
                Text("Button Color")
                    .fontWeight(.semibold)
                ColorPicker("", selection: $viewModel.buttonColor)
                    .labelsHidden()
                    .padding(.horizontal, 8)
            }

            VStack(alignment: .leading, spacing: 15) {
                Text("Background Color")
                    .fontWeight(.semibold)
                ColorPicker("", selection: $viewModel.backgroundColor)
                    .labelsHidden()
                    .padding(.horizontal, 8)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    showSettings.toggle()
                }
            }) {
                Text("Close")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}
