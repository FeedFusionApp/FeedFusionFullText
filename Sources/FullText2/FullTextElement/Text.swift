//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import Foundation

extension FullTextElement {
    public class Text: Codable {
        public let id: UUID
        public let text: String
        
        init(text: String) {
            self.id = .init()
            self.text = text
        }
    }
}
