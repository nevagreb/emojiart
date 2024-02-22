//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 05.02.2024.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palette[store.cursorIndex])
        }
    }
    
    var chooser: some View {
        Button {
            
        } label: {
            Image(systemName: "paintpalette")
        }
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
    }
}

#Preview {
    PaletteChooser(store: PaletteStore(named: "my"))
}
