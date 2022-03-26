//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation

extension FullText.Elements {
    public class Text: FullTextElement {
        public let selector: String
        public let attributes: FullTextElementAttributes
        public let text: String
        
        public init(text: String, selector: String, attributes: FullTextElementAttributes) {
            self.text = text
            self.selector = selector
            self.attributes = attributes
        }
    }
}
