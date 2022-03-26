//
//  File.swift
//  
//
//  Created by Noah Kamara on 21.03.22.
//

import SwiftSoup

extension Element {
    func flatten(isHidden: Bool = false) -> [FullText.Elements] {
        var elements: [FullText.Elements] = []
        
        for child in self.children() {
            guard let selector = try? child.cssSelector() else {
                print("NO SELECTOR")
                continue
            }
            
            let tagName = child.tagName()
            let text = try? child.text()
            var attributes: FullTextElementAttributes = .init(from: child.getAttributes(), isHiddenDefault: isHidden)
            
            // Capture "figcaption"
            if tagName == "figcaption", let text = text, case .image(let image) = elements.last {
                // If text is same as alt text, ignore
                guard image.alt?.trimmingCharacters(in: .whitespacesAndNewlines) != text.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    attributes.isHidden = true
                    continue
                }
                
                var alt: String = text
                if let imageAlt = image.alt {
                    if !text.starts(with: imageAlt) {
                        alt = imageAlt + "\n"
                    }
                    
                    alt = text
                }
                
                
                _ = elements.removeLast()
                
                let image = FullText.Elements.Image(src: image.src,
                                                    alt: alt,
                                                    selector: image.selector,
                                                    attributes: image.attributes)
                elements.append(.image(image))
                continue
            }
            
            // Capture picture
            if tagName == "picture" {
                var alt: String?
                var src: String?
                
                for child in child.children() {
                    if alt == nil {
                        if let altValue = try? child.attr("alt") {
                            alt = altValue
                        }
                        continue
                    }
                    if src == nil {
                        if child.tagName() == "source" {
                            guard let srcValue = try? child.attr("data-src-template") else {
                                print("Invalid Image. No Src Attribute")
                                continue
                            }
                            src = srcValue
                        }
                    }
                }
                
                if let src = src {
                    elements.append(.image(.init(src: src, alt: alt, selector: selector, attributes: attributes)))
                    continue
                }
            }
            
            // Headings
            if tagName.starts(with: "h") && tagName.count == 2 {
                if let text = text {
                    elements.append(.heading(.init(text: text, selector: selector, attributes: attributes)))
                    continue
                }
            }
            
            // Verify the element has no children or no text of its own
            guard child.children().count == 0 || !child.ownText().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                elements.append(contentsOf: child.flatten(isHidden: attributes.isHidden))
                continue
            }
        
            switch tagName {
                case "p", "span", "a":
                    if let text = text {
                        // If last element is image, this might be a caption
                        if case .image(let image) = elements.last {
                            // If text is same as alt text, ignore
                            if image.alt?.trimmingCharacters(in: .whitespacesAndNewlines) == text.trimmingCharacters(in: .whitespacesAndNewlines) {
                                attributes.isHidden = true
                            }
                        }
                        
                        if child.hasAttr("href") {
                            elements.append(.paragraph(.init(text: text, selector: selector, attributes: attributes)))
                        } else {
                            elements.append(.paragraph(.init(text: text, selector: selector, attributes: attributes)))
                        }
                    }
                    
                case "h1", "h2", "h3", "h4":
                    if let text = text {
                        elements.append(.heading(.init(text: text, selector: selector, attributes: attributes)))
                    }
                    
                case "img":
                    let attr = child.getAttributes()
                    let src = attr?.getNotEmpty(key: "data-src") ?? attr?.getNotEmpty(key: "src")
                    guard let src = src, !src.isEmpty else {
                        print("Invalid Image. No Src Attribute")
                        continue
                    }
                    let alt = try? child.attr("alt")
                    elements.append(.image(.init(src: src, alt: alt, selector: selector, attributes: attributes)))
                    
                default:
                    guard let text = text else {
                        continue
                    }
                    elements.append(.paragraph(.init(text: text, selector: selector, attributes: attributes)))
            }
        }
        
        return elements
    }
}
