//
//  File.swift
//  
//
//  Created by Noah Kamara on 24.03.22.
//

import Foundation
import SwiftSoup

extension FullText {
    internal static func applySiteRules(_ document: inout Document, url: URL) {
        guard let resourcePath = Bundle.module.url(forResource: "site-rules", withExtension: "json"),
              let data = try? Data(contentsOf: resourcePath),
              let siteRuleDoc = try? JSONDecoder().decode(SiteRuleDoc.self, from: data)
        else {
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
                if rule.isDisabled {
                    print("  skipping rule '\(rule.selector)'")
                    continue
                }
                print("  applying rule '\(rule.selector)'")
                let element = try? document.select(rule.selector)
                _ = try? element?.attr("feedfusion-hidden", "true")
                _ = try? element?.attr("feedfusion-reason", "\(site.key) - \(rule.name)")
            }
        }
    }
}
