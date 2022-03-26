//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation
import SwiftSoup

public protocol FullTextElement: Identifiable, Codable {
    var selector: String { get }
    var attributes: FullTextElementAttributes { get }
}

public struct FullTextElementAttributes: Codable {
    public var isHidden: Bool
    
    init(from attrib: Attributes?, isHiddenDefault: Bool) {
        self.init(isHidden: attrib?.get(key: "feedfusion-hidden") == "true" || isHiddenDefault)
    }
    
    init(isHidden: Bool) {
        self.isHidden = isHidden
    }
    
    public static let `default`: FullTextElementAttributes = .init(isHidden: false)
}

extension FullTextElement {
    public var id: String { selector }
}
