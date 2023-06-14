//
//  ContentView.swift
//  MacSageApp
//
//  Created by Chris Dillard on 4/22/23.
//

import SwiftUI
let logoAscii6 = """
╭╮╱╱╱╱╱╱╱╱╱╱╱╱╭━━━╮
┃┃╱╱╱╱╱╱╱╱╱╱╱╱┃╭━╮┃
┃┃╱╱╭━━┳━━┳┳━━┫╰━━┳━━┳━━┳━━╮
┃┃╱╭┫╭╮┃╭╮┣┫╭━┻━━╮┃╭╮┃╭╮┃┃━┫
┃╰━╯┃╰╯┃╰╯┃┃╰━┫╰━╯┃╭╮┃╰╯┃┃━┫
╰━━━┻━━┻━╮┣┻━━┻━━━┻╯╰┻━╮┣━━╯
╱╱╱╱╱╱╱╭━╯┃╱╱╱╱╱╱╱╱╱╱╭━╯┃
╱╱╱╱╱╱╱╰━━╯╱╱╱╱╱╱╱╱╱╱╰━━╯
"""
struct ContentView: View {
    var body: some View {
        VStack {
            Text(logoAscii6)
                .font(.system(size: 20, design: .monospaced))
                .minimumScaleFactor(0.05)
                .foregroundColor(.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        .ignoresSafeArea()
        .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
