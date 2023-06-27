//
//  KeyboardAdaptive.swift
//  KeyboardAvoidanceSwiftUI
//

import SwiftUI
import Combine

/// Note that the `KeyboardAdaptive` modifier wraps your view in a `GeometryReader`, 
/// which attempts to fill all the available space, potentially increasing content view size.
struct KeyboardAdaptive: ViewModifier {
    @State private var bottomPadding: CGFloat = 0
    @Binding var keyboardHeight: CGFloat
    @Binding var frame: CGRect
    @Binding var position: CGSize
    @Binding var resizeOffset: CGSize
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .padding(.bottom, keyboardHeight == 0 ? 0 : self.bottomPadding)
#if !os(macOS)

                .onReceive(Publishers.keyboardHeight) { keyboardHeight in

                    if gestureDebugLogs {
                        
                        print("keyboardAdaptive")
                        print("frame = \(frame)")
                        print("position = \(position)")
                        print("resizeOffset = \(resizeOffset)")
                    }

                    let keyboardTop = geometry.frame(in: .global).height - keyboardHeight

                    let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
                    self.bottomPadding = min(self.keyboardHeight,
                                             self.keyboardHeight == 0 ? 0 : max(0, focusedTextInputBottom - keyboardTop - geometry.safeAreaInsets.bottom - 78))
                    if gestureDebugLogs {
                        
                        print("bottomPadding = \(bottomPadding)")
                    }

            }
#endif
            .animation(.easeOut(duration: 0.16))
        }
    }
}

extension View {
    func keyboardAdaptive(keyboardHeight: Binding<CGFloat>, frame: Binding<CGRect>, position: Binding<CGSize>, resizeOffset: Binding<CGSize>) -> some View {
        ModifiedContent(content: self, modifier: KeyboardAdaptive(keyboardHeight: keyboardHeight, frame: frame, position: position, resizeOffset: resizeOffset))
    }
}
