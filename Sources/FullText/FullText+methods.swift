//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation
import SwiftSoup
import Readability

extension FullText {
    internal static var siteRules: SiteRuleDoc {
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
            
            var elements = [FullText.Elements]()
            
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
                                           excerpt: article?.excerpt,
                                           byline: article?.byline,
                                           elements: elements,
                                           readabilityHTML: try? document.html())
            
            return .success(fullText)
        } catch {
            return .failure(.swiftSoup(error))
        }
    }
}
