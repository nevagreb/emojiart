//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 30.01.2024.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Main")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumetView(document: defaultDocument)
                .environmentObject(paletteStore)
        }
    }
}
