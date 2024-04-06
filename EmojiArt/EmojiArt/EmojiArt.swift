//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 30.01.2024.
//

import Foundation

struct NewStruct {
    var a: String
}

struct EmojiArt: Codable {
    var background: URL?
    private(set) var emojis = [Emoji]()
    
    private var uniqueEmojiId = 0
    
    func json() throws -> Data {
        let encoded = try JSONEncoder().encode(self)
        print("EmojiArt = \(String(data: encoded, encoding: .utf8) ?? "nil")")
        return encoded
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArt.self, from: json)
    }
    
    init() {
        
    }
    
    mutating func changeEmojiZoom(id: Emoji.ID, zoom: Double) {
        if let index = findIndex(id) {
            emojis[index]._zoom *= zoom
        }
    }
    
    mutating func addEmojiOffset(id: Emoji.ID, offset: Emoji.Position) {
        if let index = findIndex(id) {
            emojis[index]._offset += offset
        }
    }
    
    mutating func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        uniqueEmojiId += 1
        let zoom = 1.0
        let offset = Emoji.Position.zero
        emojis.append(Emoji(string: emoji, position: position, size: size, _zoom: zoom, _offset: offset, id: uniqueEmojiId))
    }
    
    mutating func deleteEmoji(id: Int) {
        if let index = findIndex(id) {
            emojis.remove(at: index)
        }
    }
    
    func findIndex(_ id: Int) -> Int? {
        emojis.firstIndex(where: {id == $0.id})
    }
    
    struct Emoji: Identifiable, Codable {
        let string: String
        var position: Position
        var size: Int
        var _zoom: Double
        var _offset: Position
        var id: Int
        
        struct Position: Codable {
            var x: Int
            var y: Int
            
            static let zero = Self(x: 0, y: 0)
            
            static func +(lhs: Position, rhs: Position) -> Position {
                Position(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
            }
            
            static func +=(lhs: inout Position, rhs: Position) {
                lhs = lhs + rhs
            }
        }
    }
}

