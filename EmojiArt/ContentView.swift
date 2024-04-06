//
//  ContentView.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 30.01.2024.
//

import SwiftUI

struct ContentView: View {
//    @Environment(\.self) var environment
    @State var color: Color = Color.gray
    @State var components: Color.Resolved?
    
    var body: some View {
        VStack {
            ColorPicker("Choose your color", selection: $color)
            
//            if let components {
//                Text("R: \(components.red)")
//                Text("G: \(components.green)")
//                Text("B: \(components.blue)")
//                Text("A: \(components.opacity)")
//            }
            
            
        }
        .onChange(of: color, initial: true) {
            //components = color.resolve(in: environment)
            print(UIColor(color).cgColor.components ?? 0)
        }
    }
}

#Preview {
    ContentView()
}

