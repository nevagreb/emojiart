//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 30.01.2024.
//

import SwiftUI


class EmojiArtDocument: ObservableObject {
    typealias Emoji = EmojiArt.Emoji
    
    @Published private var emojiArt = EmojiArt() {
        didSet {
            autosave()
            
            if emojiArt.background != oldValue.background {
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
    private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Avtosaved.emojiart")
    
    private func autosave() {
            save(to: autosaveURL)
            print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url: URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
            
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
    
    init() {
        if let data = try? Data(contentsOf: autosaveURL),
           let autosavedEmojiArt = try? EmojiArt(json: data) {
            emojiArt = autosavedEmojiArt
        }
    }
    
    
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    @Published var backround: Background = .none
    
    //MARK: - Background Image
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            backround = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    backround = .found(image)
                }
            } catch {
                backround = .failed("Couldn't set backround: \(error.localizedDescription)")
            }
        } else {
            backround = .none
        }
    }

    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
            case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
    
        var uiImage: UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var urlBeingFetched: URL? {
            switch self {
            case .fetching(let url): return url
            default: return nil
            }
        }
        
        var isFetching: Bool {
            urlBeingFetched != nil
        }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
        
    }
    
    
    // MARK: - Intent(s)
    
    func setBackground(_ url: URL?) {
        emojiArt.background = url
    }
    
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: Int) {
        emojiArt.addEmoji(emoji, at: position, size: size)
    }
    
    func deleteEmoji(id: Int) {
        emojiArt.deleteEmoji(id: id)
    }
    
    func changeEmojiZoom(id: Emoji.ID, zoom: Double) {
        emojiArt.changeEmojiZoom(id: id, zoom: zoom)
    }
    
    func addEmojiOffset(id: Emoji.ID, offset: CGSize) {
        emojiArt.addEmojiOffset(id: id, offset: EmojiArt.Emoji.Position(offset))
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    
    var zoom: CGFloat {
        CGFloat(_zoom)
    }
    
    var offset: CGSize {
        CGSize(width: _offset.x, height: _offset.y)
    }

}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(x: center.x + CGFloat(x), y: center.y - CGFloat(y))
    }
    
    init(_ offset: CGSize) {
        self.x = Int(offset.width)
        self.y = Int(offset.height)
    }
}

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width/2, y: center.y - size.height/2), size: size)
    }
}
