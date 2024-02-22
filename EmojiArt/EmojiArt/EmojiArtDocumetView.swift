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
            PaletteChooser()
                .font(.system(size: paletteEmojiSize))
                .padding(.horizontal)
                .scrollIndicators(.hidden)
        }
    }
    
    private var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                if document.backround.isFetching {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.blue)
                        .position(Emoji.Position.zero.in(geometry))
                }
                documentContents(in: geometry)
                    .scaleEffect(zoom * gestureZoom)
                    .offset(pan + gesturePan)
            }
            .gesture(selectedEmojis.isEmpty ? panGesture.simultaneously(with: zoomGesture) : nil)
            .dropDestination(for: Sturldata.self) {sturldata, location in
                return drop(sturldata, at: location, in: geometry)
            }
        }
    }
    
    @State private var zoom: CGFloat = 1
    @State private var emojiZoom = [Emoji.ID : CGFloat]()
    
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var emojiGestureZoom: CGFloat = 1
    
    @State private var pan: CGSize = .zero
    @State private var emojiPan = [Emoji.ID : CGSize]()
    
    @GestureState private var gesturePan: CGSize = .zero
    @GestureState private var emojiGesturePan: CGSize = .zero
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating(selectedEmojis.isEmpty ? $gestureZoom : $emojiGestureZoom) { value, gestureState, _ in
                gestureState = value
            }
            .onEnded { endingPinchScale in
                if selectedEmojis.isEmpty {
                    zoom *= endingPinchScale
                } else {
                    selectedEmojis.forEach { id in
                            emojiZoom[id]! *= endingPinchScale
                    }
                }
            }
    }
    
    private var panGesture: some Gesture {
        DragGesture()
            .updating(selectedEmojis.isEmpty ? $gesturePan : $emojiGesturePan) { value, gestureState, _ in
                gestureState = value.translation
            }
            .onEnded { value in
                if selectedEmojis.isEmpty {
                    pan += value.translation
                } else {
                    selectedEmojis.forEach { id in
                        emojiPan[id]! += value.translation
                    }
                }
            }
    }
    
    @ViewBuilder
    private func documentContents(in geometry: GeometryProxy) -> some View {
//        AsyncImage(url: document.backround) {phase in
//            if let image = phase.image {
//                image
//            } else if let url = document.backround {
//                if phase.error != nil {
//                    Text("\(url)")
//                } else {
//                    ProgressView()
//                }
//            }
//        }
        if let uiImage = document.backround.uiImage {
            Image(uiImage: uiImage)
                .position(Emoji.Position.zero.in(geometry))
                .onTapGesture {
                    selectedEmojis.removeAll()
                }
        }
        
        ForEach(document.emojis) {emoji in
            Text(emoji.string)
                .font(emoji.font)
                .border(isSelected(emoji) ? Color.blue : .clear)
            
                .contextMenu {
                    Button("Delete", role: .destructive) {
                        document.deleteEmoji(id: emoji.id)
                    }
                }
            
                .scaleEffect((emojiZoom[emoji.id] ?? 1) * (isSelected(emoji) ? emojiGestureZoom : 1))
                .offset((emojiPan[emoji.id] ?? .zero) + (isSelected(emoji) ? emojiGesturePan : .zero))
                .gesture(isSelected(emoji) ? panGesture.simultaneously(with: zoomGesture) : nil)
                .position(emoji.position.in(geometry))
            
                .onAppear {
                    emojiZoom[emoji.id] = 1
                    emojiPan[emoji.id] = .zero
                }
            
                .onTapGesture {
                    if isSelected(emoji) {
                        selectedEmojis.remove(emoji.id)
                    } else {
                        selectedEmojis.insert(emoji.id)
                    }
                }
        }
    }
    
    @State private var selectedEmojis = Set<Emoji.ID>()
    
    private func isSelected(_ emoji: Emoji) -> Bool {
        selectedEmojis.contains(emoji.id)
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


//#Preview {
//    EmojiArtDocumetView(document: EmojiArtDocument())
//        .environmentObject(PaletteStore(named: "Preview"))
//}
