//
//  SettingsVIew.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/25/23.
//

import Foundation
import SwiftUI


var windowIndex = 0
struct AddView: View {
    @Binding var showAddView: Bool
    @ObservedObject var viewModel: SettingsViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button("New File") {
                    print("mnew File")
                    print("mnew File")

                }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Button("New Window") {
                    print("mnew window")
                    showAddView.toggle()

                    windowIndex += 1
#if !os(macOS)

                    switch windowIndex {
                    case 1: LCManager.shared2.isVisible.toggle()
                    case 2: LCManager.shared3.isVisible.toggle()

                    case 3: LCManager.shared4.isVisible.toggle()

                    case 4: LCManager.shared5.isVisible.toggle()

                    case 5: LCManager.shared6.isVisible.toggle()
                    default: break

                    }
                    #endif
                }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)


                Button("New Webview") {
                    print("mnew Webview")
                    showAddView.toggle()
                    viewModel.showWebView = true
                }
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Button(action: {
                    withAnimation {
                        showAddView.toggle()
                    }
                }) {
                    Text("Close")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(viewModel.buttonColor)
                        .cornerRadius(8)
                }
                .padding(.bottom)
            }
            .padding()
#if !os(macOS)

            .background(Color(.systemBackground))
#else
            .background(Color(.black))
#endif
            .cornerRadius(16)
        }
        .scrollIndicators(.visible)
    }
}
