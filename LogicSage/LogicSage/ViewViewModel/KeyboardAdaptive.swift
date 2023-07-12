//
//  KeyboardAdaptive.swift
//  KeyboardAvoidanceSwiftUI
//
//
//import SwiftUI
//import Combine
//#if !os(macOS)
//
//struct KeyboardAdaptive: ViewModifier {
//    @State private var bottomPadding: CGFloat = 0
//    @Binding var keyboardHeight: CGFloat
//    @Binding var frame: CGRect
//    @Binding var position: CGSize
//    @Binding var resizeOffset: CGSize
//
//    var keyboardTop: CGFloat
//    var safeAreaInsetBottom: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//            .padding(.bottom, keyboardHeight == 0 ? 0 : self.bottomPadding)
//        #if !os(tvOS)
//            .onReceive(Publishers.keyboardHeight) { keyboardHeight in
//
//                if gestureDebugLogs {
//
//                    logD("keyboardAdaptive")
//                    logD("keyboardHeight = \(keyboardHeight)")
//
//                    logD("frame = \(frame)")
//                    logD("position = \(position)")
//                    logD("resizeOffset = \(resizeOffset)")
//                }
//
//                let focusedTextInputBottom = UIResponder.currentFirstResponder?.globalFrame?.maxY ?? 0
//                self.bottomPadding = min(self.keyboardHeight,
//                                         self.keyboardHeight == 0 ? 0 : max(0, focusedTextInputBottom - keyboardTop - safeAreaInsetBottom - 78))
//                if gestureDebugLogs {
//
//                    logD("bottomPadding = \(bottomPadding)")
//                }
//
//        }
//        #endif
//        .animation(.easeOut(duration: 0.16))
//    }
//}
//
//extension View {
//    func keyboardAdaptive(keyboardHeight: Binding<CGFloat>, frame: Binding<CGRect>, position: Binding<CGSize>, resizeOffset: Binding<CGSize>, keyboardTop: CGFloat, safeAreaInsetBottom: CGFloat) -> some View {
//        ModifiedContent(content: self, modifier: KeyboardAdaptive(keyboardHeight: keyboardHeight, frame: frame, position: position, resizeOffset: resizeOffset, keyboardTop: keyboardTop, safeAreaInsetBottom: safeAreaInsetBottom))
//    }
//}
//#endif
