//
//  ContentView.swift
//  SwiftSageiOS
//
//  Created by Chris Dillard on 4/23/23.
//

import SwiftUI
import Foundation

let consoleManager = LCManager.shared

struct ContentView: View {
    init() {
        consoleManager.isVisible = true
    }
    var body: some View {
        VStack {
            Spacer()
            Button("LOG") {
                consoleManager.isVisible = true
                consoleManager.print("Swifty!")
                consoleManager.print("Swifty!")

                consoleManager.print("Swifty!")

            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)

            Text("🚀🔥 Welcome to SwiftSage 🧠💥")
                .foregroundColor(.black)
                .font(.largeTitle)
                .fontWeight(.heavy)

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
