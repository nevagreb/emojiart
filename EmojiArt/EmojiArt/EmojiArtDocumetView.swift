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
//            .onChange(of: document.backround.uiImage) { uiImage, _ in
//                zoomToFit(uiImage?.size, in: geometry)
//            }
        }
    }
        
//    private func zoomToFit(_ size: CGSize?, in geometry: GeometryProxy) {
//        if let size {
//            zoomToFit(CGRect(center: .zero, size: size), in: geometry)
//        }
//    }
//    
//    private func zoomToFit(_ rect: CGRect, in geometry: GeometryProxy) {
//        withAnimation {
//            if rect.size.width > 0, rect.size.height > 0, geometry.size.width > 0, geometry.size.height > 0 {
//                let hZoom = geometry.size.width / rect.size.width
//                let vZoom = geometry.size.height / rect.size.height
//                zoom = min(hZoom, vZoom)
//                pan = CGSize(width: -rect.midX * zoom, height: -rect.midY * zoom )
//            }
//        }
//    }
    
    @State private var zoom: CGFloat = 1
    @GestureState private var gestureZoom: CGFloat = 1
    @GestureState private var emojiGestureZoom: CGFloat = 1
    
    @State private var pan: CGSize = .zero
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
                        document.changeEmojiZoom(id: id, zoom: endingPinchScale)
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
                        document.addEmojiOffset(id: id, offset: value.translation)
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
                .scaleEffect(addZoom(to: emoji))
                .offset(addOffset(to: emoji))
                .gesture(isSelected(emoji) ? panGesture.simultaneously(with: zoomGesture) : nil)
                .position(emoji.position.in(geometry))
            
                .onTapGesture {
                    if isSelected(emoji) {
                        selectedEmojis.remove(emoji.id)
                    } else {
                        selectedEmojis.insert(emoji.id)
                    }
                }
        }
    }
    
    private func addZoom(to emoji: Emoji) -> CGFloat {
        emoji.zoom * (isSelected(emoji) ? emojiGestureZoom : 1)
    }
    
    private func addOffset(to emoji: Emoji) -> CGSize {
        emoji.offset + (isSelected(emoji) ? emojiGesturePan : .zero)
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
