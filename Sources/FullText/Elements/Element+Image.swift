//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation

extension FullText.Elements {
    public struct Image: FullTextElement {
        public let selector: String
        public let attributes: FullTextElementAttributes
        public let src: String
        public let alt: String?
        
        public init(src: String, alt: String?, selector: String, attributes: FullTextElementAttributes) {
            self.src = src
            self.alt = alt
            self.selector = selector
            self.attributes = attributes
        }
    }
}
