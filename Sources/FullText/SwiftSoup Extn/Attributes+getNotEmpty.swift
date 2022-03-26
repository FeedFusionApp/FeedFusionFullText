//
//  File.swift
//  
//
//  Created by Noah Kamara on 26.03.22.
//

import Foundation
import SwiftSoup

extension Attributes {
    func getNotEmpty(key: String) -> String? {
        let value = self.get(key: key)
        guard !value.isEmpty else {
            return nil
        }
        return value
    }
}
