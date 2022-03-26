//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import Foundation

internal typealias SiteRuleDoc = [String: [SiteRule]]

struct SiteRule: Decodable {
    let name: String
    let selector: String
}

enum SiteElementOperation: String, Decodable {
    case remove
}
