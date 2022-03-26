//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation

internal typealias SiteRuleDoc = [String: [SiteRule]]

struct SiteRule: Decodable {
    let name: String
    let selector: String
    let disabled: Bool?
    
    var isDisabled: Bool { disabled ?? false }
}

enum SiteElementOperation: String, Decodable {
    case remove
}
