//
//  EmojiArtDocumetView.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 31.01.2024.
//

import SwiftUI

struct EmojiArtDocumetView: View {
    typealias Emoji = EmojiArt.Emoji
    @ObservedObject var document: EmojiArtDocument
    
    private let emojis = ["🪿", "🦆", "🐝", "🐛", "🐌", "🦋", "🪱", "🐞", "🪰", "🪳", "🪲", "🐢", "🦂", "🦟", "🦕", "🦖", "🦧", "🦣", "🦭", "🐅", "🐄", "🐏", "🦙", "🐖", "🫏", "🐁", "🐓", "🦚", "🦢", "🦦", "🌲", "🌱", "🌳", "☘️", "🪷", "🌕", "🌙", "☁️", "🌧️", "☂️", "🍏", "🍓", "🥦", "🥑", "🥕", "🫑", "🌶️", "🍖", "🍗", "🚘", "🚔", "🛺", "✈️", "🏦", "💒", "🏛️", "🧸", "🪑", "💃", "🕺", "👯‍♂️", "👨‍🌾"]
    private let emoji1 = "🐶🐱🐭🐹🐰🦊🐻"
    
    private let paletteEmojiSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            PaletteChooser(store: )
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(panGesture.simultaneously(with: zoomGesture))
            .dropDestination(for: Sturldata.self) {sturldata, location in
                return drop(sturldata, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var pan: CGSize = .zero
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var gesturePan: CGSize = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                    zoom *= endingPinchScale
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating($gesturePan) { value, gesturePan, _ in
                gesturePan = value.translation
            }
            .onEnded { value in
                pan += value.translation
            }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
        AsyncImage(url: document.backround)
            .position(Emoji.Position.zero.in(geometry))
        ForEach(document.emojis) {emoji in
            Text(emoji.string)
                .font(emoji.font)
                .position(emoji.position.in(geometry))
        }
    }
    
    private func drop(_ sturldatas: [Sturldata], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        for sturldata in sturldatas {
            switch sturldata {
            case .url(let url):
                document.setBackground(url)
                return true
            case .string(let emoji):
                document.addEmoji(emoji, at: emojiPosition(at: location, in: geometry), size: Int(paletteEmojiSize / zoom))
                return true
            default:
                break
            }
        }
        return false
    }
    
    private func emojiPosition(at location: CGPoint, in geometry: GeometryProxy) -> Emoji.Position {
        let center = geometry.frame(in: .local).center
        return Emoji.Position (
            x: Int((location.x - center.x - pan.width) / zoom),
            y: Int(-(location.y - center.y - pan.height) / zoom)
        )
    }
}


struct ScrollingEmojis: View {
    var emojis: [String]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
        }
    }
    
    init(_ emojis: [String]) {
        self.emojis = emojis
    }
    
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map(String.init)
    }
}

#Preview {
    EmojiArtDocumetView(document: EmojiArtDocument())
}

extension CGSize {
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func +=(lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }
}

extension String {
    var uniqued: String {
        reduce(into: "") { sofar, element in
            if !sofar.contains(element) {
                sofar.append(element)
            }
        }
    }
}
