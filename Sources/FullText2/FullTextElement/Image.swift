//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import Foundation

extension FullTextElement {
    public class Image: Identifiable, Codable {
        public let id: UUID
        public let src: String
        public let alt: String?
        
        internal init(src: String, alt: String?) {
            self.id = .init()
            self.src = src
            self.alt = alt
        }
    }
}
