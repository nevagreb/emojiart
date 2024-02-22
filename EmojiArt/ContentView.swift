//
//  ContentView.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 30.01.2024.
//

import SwiftUI

struct ContentView: View {

    
    var body: some View {
        Text("Options")
            .contextMenu {
                Button {
                    print("Change country setting")
                } label: {
                    Label("Choose Country", systemImage: "globe")
                }

                Button {
                    print("Enable geolocation")
                } label: {
                    Label("Detect Location", systemImage: "location.circle")
                }
            }
    }
   

}

#Preview {
    ContentView()
}

