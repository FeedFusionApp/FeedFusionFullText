//
//  File.swift
//  
//
//  Created by Noah Kamara on 13.03.22.
//

import XCTest
@testable import Readability

final class ReadabilityTests: XCTestCase {
    
    let readability = Readability()
    
    let urls: [URL] = [
        .init(string: "https://www.yourlocalguardian.co.uk/news/19987088.sutton-irish-bar-offering-free-pints-st-patricks-day/?ref=rss")!
    ]
    
    @available(macOS 12.0, *)
    func testExample() async throws {
        let (data, _ ) = try await URLSession.shared.data(from: urls.first!)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            return
        }
        
        let article = readability.parseArticle(html: htmlString)
        
        XCTAssertNotNil(article)
    }
}
