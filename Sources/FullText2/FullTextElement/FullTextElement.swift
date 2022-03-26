//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import Foundation
import SwiftSoup

public enum FullTextElement: Identifiable, Codable {
    public var id: UUID {
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
    
    var isImage: Bool {
        if case .image = self {
            return true
        }
        return false
    }
    
    case images([Image])
    case image(Image)
    case paragraph(Text)
    case heading(Text)
}
