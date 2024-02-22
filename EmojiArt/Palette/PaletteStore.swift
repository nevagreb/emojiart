//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 05.02.2024.
//

import SwiftUI

class PaletteStore: ObservableObject {
    let name: String
    @Published var palette: [Palette] {
        didSet {
            if palette.isEmpty, !oldValue.isEmpty {
                palette = oldValue
            }
        }
    }
 
    init(named name: String) {
        self.name = name
        palette = Palette.builins
        if palette.isEmpty {
            palette = [Palette(name: "Warning", emojis: "❗️")]
        }
    }
    
    @Published private var _cursorIndex = 0
    
    var cursorIndex: Int {
        get { boundsCheckedPalettes(_cursorIndex) }
        set { _cursorIndex = boundsCheckedPalettes(newValue) } 
    }
    
    private func boundsCheckedPalettes(_ index: Int) -> Int {
        var index = index % palette.count
        if index < 0 {
            index += palette.count
        }
        return index
    }
}
