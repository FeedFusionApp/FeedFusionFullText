//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation

extension FullText {
    public enum Elements: Identifiable, Codable {
        public var attributes: FullTextElementAttributes {
            switch self {
                case .images(let array):
                    return array.first!.attributes
                case .image(let image):
                    return image.attributes
                case .paragraph(let text):
                    return text.attributes
                case .heading(let text):
                    return text.attributes
            }
        }
        public var id: String {
            switch self {
                case .image(let image):
                    return image.id
                    
                case .paragraph(let text):
                    return text.id
                    
                case .heading(let text):
                    return text.id
                    
                case .images(let images):
                    return images.first?.id ?? .init()
            }
        }
        
        case images([Image])
        case image(Image)
        case paragraph(Text)
        case heading(Text)
    }
}
