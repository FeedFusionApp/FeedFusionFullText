import XCTest
@testable import FullText

@available(macOS 12.0, *)
final class FeedFusionFullTextTests: XCTestCase {
    let urls: [URL] = [
        .init(string: "https://www.spiegel.de/netzwelt/web/bundeskriminalamt-ermittelt-hackerangriff-auf-rosneft-deutschland-a-74e3a53a-e747-4500-8198-ea6780a7d79a")!
    ]
    
    
    func testExample() async throws {
        let fullText = await FullText.parse(url: urls.first!)
        XCTAssertNotNil(fullText)
    }
}
