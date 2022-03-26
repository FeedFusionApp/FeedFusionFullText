//
//  File.swift
//  
//
//  Created by Noah Kamara on 13.03.22.
//

import Foundation
import JavaScriptCore

public enum ReadabilityError: Error {
    case jsContextError
    case invalidResult(JSValue?)
    case unknown(Error)
}
