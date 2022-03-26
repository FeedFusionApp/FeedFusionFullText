//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import Foundation
import Readability

public enum FullTextError: Error {
    static let downloadError: Self = .downloadError(nil)
    
    case readabilityError(ReadabilityError)
    case downloadError(Error?)
    case swiftSoup(Error)
    case contentEmpty
}
