//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation
import SwiftSoup
import Readability
import Logger

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
    
    public static func parse(url: URL, logger: Logger = .init("FeedFusion", "FullText", level: .verbose, mode: .icons)) async -> Result<FullText, FullTextError> {
        let tag = UUID().uuidString
        
        logger.info("parsing article '\(url.absoluteString)'", tag: tag)
        
        var html: String?
        do {
            logger.debug("download - attempting", tag: tag)
            html = try await downloadHTML(from: url)
            logger.debug("download - success", tag: tag)
        } catch {
            logger.error("download - failure: \(error)", tag: tag)
            return .failure(.downloadError(error))
        }
        
        guard let html = html else {
            logger.error("download - html was empty", tag: tag)
            return .failure(.downloadError)
        }
        
        var article: Article?
        do {
            logger.debug("parser - attempting", tag: tag)
            article = try Readability.shared.parseArticle(html: html).get()
            logger.debug("parser - success", tag: tag)
        } catch let error as ReadabilityError {
            logger.error("parser - failure: \(error)", tag: tag)
            return .failure(.readabilityError(error))
        } catch {
            logger.error("parser - failure: \(error)", tag: tag)
            return .failure(.readabilityError(.unknown(error)))
        }
        
        guard let processedHTML = article?.content else {
            logger.error("parser - html was empty", tag: tag)
            return .failure(.contentEmpty)
        }
        
        do {
            logger.debug("postprocessing - parsing document", tag: tag)
            var document = try SwiftSoup.parseBodyFragment(processedHTML)
            
            var elements = [FullText.Elements]()
            
            logger.debug("postprocessing - applying site-ruls", tag: tag)
            applySiteRules(&document, url: url, logger: logger, tag: tag)
            
            logger.debug("postprocessing - flattening document", tag: tag)
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
            
            logger.info("success", tag: tag)
            return .success(fullText)
        } catch {
            logger.error("failure: \(error)", tag: tag)
            return .failure(.swiftSoup(error))
        }
    }
}
