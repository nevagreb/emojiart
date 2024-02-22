//
//  PaletteStore.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 05.02.2024.
//

import SwiftUI

extension UserDefaults {
    func palette(forKey key: String) -> [Palette] {
        if let jsonData = data(forKey: key),
           let decodedPalette = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            return decodedPalette
        } else {
            return []
        }
    }
    func set(_ palette: [Palette], forKey key: String) {
        let data = try? JSONEncoder().encode(palette)
        set(data, forKey: key)
    }
}

class PaletteStore: ObservableObject {
    let name: String
    
    private var userDefaultsKey: String { "PaletteStore" + name}
    
    var palette: [Palette] {
        get {
            UserDefaults.standard.palette(forKey: userDefaultsKey)
        }
        set {
            if !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                objectWillChange.send()
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        if palette.isEmpty {
            palette = Palette.builins
            if palette.isEmpty {
                palette = [Palette(name: "Warning", emojis: "❗️")]
            }
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
