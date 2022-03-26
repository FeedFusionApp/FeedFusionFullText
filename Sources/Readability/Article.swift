//
//  File.swift
//  
//
//  Created by Noah Kamara on 13.03.22.
//

import Foundation

public class Article: NSObject {
    public override var description: String {
        var text: String = "Article("
        text += "\n  title: \(title ?? "-")"
        text += "\n  content: \(content ?? "-")"
        text += "\n  textContent: \(textContent ?? "-")"
        text += "\n  length: \(length?.description ?? "-")"
        text += "\n  excerpt: \(excerpt ?? "-")"
        text += "\n  byline: \(byline ?? "-")"
        text += "\n  dir: \(dir ?? "-")"
        text += "\n  siteName: \(siteName ?? "-")"
        text += "\n  lang: \(lang ?? "-")"
        text += "\n)"
        return text
    }
    
    internal init(title: String?, content: String?, textContent: String?, length: Int?, excerpt: String?, byline: String?, dir: String?, siteName: String?, lang: String?) {
        self.title = title
        self.content = content
        self.textContent = textContent
        self.length = length
        self.excerpt = excerpt
        self.byline = byline
        self.dir = dir
        self.siteName = siteName
        self.lang = lang
    }
    
    convenience init(from object: [AnyHashable: Any]) {
        self.init(title: object["title"] as? String,
                  content: object["content"] as? String,
                  textContent: object["textContent"] as? String,
                  length: object["length"] as? Int,
                  excerpt: object["excerpt"] as? String,
                  byline: object["byline"] as? String,
                  dir: object["dir"] as? String,
                  siteName: object["siteName"] as? String,
                  lang: object["lang"] as? String)
    }
    
    /// article title;
    public var title: String?
    
    /// HTML string of processed article content;
    public var content: String?
    
    /// text content of the article, with all the HTML tags removed;
    public var textContent: String?
    
    /// length of an article, in characters;
    public var length: Int?
    
    /// article description, or short excerpt from the content;
    public var excerpt: String?
    
    /// author metadata;
    public var byline: String?
    
    /// content direction;
    public var dir: String?
    
    /// name of the site;
    public var siteName: String?
    
    /// content language;
    public var lang: String?
}
