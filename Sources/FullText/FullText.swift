//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation

public class FullText: Codable {
    public let title: String?
    public let excerpt: String?
    public let byline: String?
    public let elements: [Elements]
    public let readabilityHTML: String?
    
    public init(title: String?, excerpt: String?, byline: String?, elements: [Elements], readabilityHTML: String?) {
        self.title = title
        self.excerpt = excerpt
        self.elements = elements
        self.byline = byline
        self.readabilityHTML = readabilityHTML
    }
}
