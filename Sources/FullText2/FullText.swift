//
//  File.swift
//  
//
//  Created by Noah Kamara on 13.03.22.
//

import Foundation
import Readability
import SwiftSoup
import SwiftUI

public class FullText: Codable {
    public let title: String?
    public let image: FullTextElement.Image?
    public let excerpt: String?
    public let byline: String?
    public let elements: [FullTextElement]
    
    init(title: String?, image: FullTextElement.Image?, excerpt: String?, byline: String?, elements: [FullTextElement]) {
        self.title = title
        self.image = image
        self.excerpt = excerpt
        self.elements = elements
        self.byline = byline
    }
}



extension FullText {
    static var siteRules: SiteRuleDoc {
        guard let resourcePath = Bundle.module.url(forResource: "site-rules", withExtension: "json"),
              let data = try? Data(contentsOf: resourcePath),
              let rules = try? JSONDecoder().decode(SiteRuleDoc.self, from: data)
        else {
            preconditionFailure("Couldnt retrieve readability.js")
        }
        
        return rules
    }
    
    internal static func downloadHTML(from url: URL) async throws -> String? {
        let (data, _ ) = try await URLSession.shared.data(from: url)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return htmlString
    }
    
    
    public static func applySiteRules(_ document: inout Document, url: URL) {
        guard let resourcePath = Bundle.module.url(forResource: "site-rules", withExtension: "json"),
              let data = try? Data(contentsOf: resourcePath),
              let siteRuleDoc = try? JSONDecoder().decode(SiteRuleDoc.self, from: data)
        else {
            let resourcePath = Bundle.module.url(forResource: "site-rules", withExtension: "json")!
            let data = try! Data(contentsOf: resourcePath)
            try! JSONDecoder().decode(SiteRuleDoc.self, from: data)
            print("BUNDLE Couldnt retrieve site-rules.json")
            return
        }
        
        let domain = url.absoluteString
        
        for site in siteRuleDoc {
            let pred = NSPredicate(format: "self LIKE %@", site.key)
            if NSArray(object: domain).filtered(using: pred).isEmpty {
                continue
            }
            
            print("site '\(site.key)' - applying rules for")
            
            for rule in site.value {
                print("  applying rule '\(rule.selector)'")
                let element = try? document.select(rule.selector)
                _ = try? element?.remove()
            }
        }
    }
    
    public static func parse(url: URL) async -> Result<FullText, FullTextError> {
        var html: String?
        do {
            html = try await downloadHTML(from: url)
        } catch {
            return .failure(.downloadError(error))
        }
        
        guard let html = html else {
            return .failure(.downloadError)
        }
        
        
        var article: Article?
        do {
            article = try Readability.shared.parseArticle(html: html).get()
        } catch let error as ReadabilityError {
            return .failure(.readabilityError(error))
        } catch {
            return .failure(.readabilityError(.unknown(error)))
        }
        
        guard let processedHTML = article?.content else {
            return .failure(.contentEmpty)
        }
        
        do {
            var document = try SwiftSoup.parseBodyFragment(processedHTML)

            var elements = [FullTextElement]()

            applySiteRules(&document, url: url)
            for element in document.flatten() {
                switch element {
                    case .heading(let text), .paragraph(let text):
                        if text.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.text.split(separator: " ").count == 1 {
                            continue
                        }

                        if case .image(let image) = elements.last, image.alt == text.text {
                            continue
                        }

                    case .image(let image):
                        if case let .image(prevImage) = elements.last {
                            elements.removeLast()
                            elements.append(.images([image, prevImage]))
                            continue
                        }

                    default:
                        continue
                }

                elements.append(element)
            }
            
            let fullText: FullText = .init(title: article?.title,
                                           image: nil,
                                           excerpt: article?.excerpt,
                                           byline: article?.byline,
                                           elements: elements)
            
            return .success(fullText)
        } catch {
            return .failure(.swiftSoup(error))
        }
    }
}
