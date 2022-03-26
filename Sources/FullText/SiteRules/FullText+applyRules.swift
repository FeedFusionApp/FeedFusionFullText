//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation
import SwiftSoup
import Logger

extension FullText {
    internal static func applySiteRules(_ document: inout Document, url: URL, logger: Logger, tag: String) {
        guard let resourcePath = Bundle.module.url(forResource: "site-rules", withExtension: "json"),
              let data = try? Data(contentsOf: resourcePath),
              let siteRuleDoc = try? JSONDecoder().decode(SiteRuleDoc.self, from: data)
        else {
            logger.critical("applySiteRules - couldnt retrive site-rules.json", tag: tag)
            return
        }
        
        let domain = url.absoluteString
        
        for site in siteRuleDoc {
            logger.trace("applySiteRules - evaluating site: '\(site)' against domain", tag: tag)
            let pred = NSPredicate(format: "self LIKE %@", site.key)
            if NSArray(object: domain).filtered(using: pred).isEmpty {
                logger.trace("applySiteRules - site '\(site)' didnt match", tag: tag)
                continue
            }
            
            logger.debug("applySiteRules - applying rules for site: '\(site)'", tag: tag)
            for rule in site.value {
                
                if rule.isDisabled {
                    logger.trace("applySiteRules - skipping rule: '\(rule.name)' (disabled)", tag: tag)
                    continue
                }
                logger.trace("applySiteRules - applying rule: '\(rule.name)' - '\(rule.selector)'", tag: tag)
                let element = try? document.select(rule.selector)
                _ = try? element?.attr("feedfusion-hidden", "true")
                _ = try? element?.attr("feedfusion-reason", "\(site.key) - \(rule.name)")
            }
        }
    }
}
