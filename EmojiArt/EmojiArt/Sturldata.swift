//
//  Sturldata.swift
//  EmojiArt
//
//  Created by Kristina Grebneva on 01.02.2024.
//
import CoreTransferable

enum Sturldata: Transferable {
    
    case string(String)
    case url(URL)
    case data(Data)
    
    init(url: URL) {
        self = .url(url)
//        if let imageData = url.dataSchemeImageData {
//            self = .data(imageData)
//        } else {
//            self = .url(url)
//        }
    }
    
    init(string: String) {
        if string.hasPrefix("http"), let url = URL(string: string) {
            self = .url(url)
        } else {
            self = .string(string)
        }
    }
    
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation { Sturldata(string: $0) }
        ProxyRepresentation { Sturldata(url: $0) }
        ProxyRepresentation { Sturldata.data($0) }
    }
}
