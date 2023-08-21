//
//  GlobeControls.swift
//  LogicSage
//
//  Created by Chris Dillard on 8/17/23.
//
#if os(xrOS)

import SwiftUI

struct GlobeControls: View {
    @EnvironmentObject var appModel: AppModel


    var body: some View {


        HStack(spacing: 17) {
            Toggle(isOn:$appModel.isTranslating) {
                Label("Translate", systemImage: "sun.max")
            }

            .onChange(of: appModel.isTranslating) {
                print("new trans value = \($appModel.isTranslating)")
            }

            Toggle(isOn: $appModel.isRotating) {
                Label("Rotate", systemImage: "arrow.triangle.2.circlepath")
            }
            .onChange(of: appModel.isRotating) {
                print("new rot value = \($appModel.isRotating)")
            }
        }
        .toggleStyle(.button)
        .buttonStyle(.borderless)
        .labelStyle(.iconOnly)
        .padding(12)
        .glassBackgroundEffect(in: .rect(cornerRadius: 50))
    }
}

extension HorizontalAlignment {
    /// A custom alignment to center the control panel under the globe.
    private struct ControlPanelAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    /// A custom alignment guide to center the control panel under the globe.
    static let controlPanelGuide = HorizontalAlignment(
        ControlPanelAlignment.self
    )
}
#endif
