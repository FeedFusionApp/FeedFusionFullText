//
//  File.swift
//
//
//  Created by Noah Kamara on 13.03.22.
//

import Foundation
import JavaScriptCore

public class Readability {
    public static let shared: Readability = .init()
    
    private lazy var script: String = {
        guard let resourcePath = Bundle.module.url(forResource: "readability", withExtension: "js"),
              let data = try? Data(contentsOf: resourcePath),
              let string = String(data: data, encoding: .utf8)
        else {
            preconditionFailure("Couldnt retrieve readability.js")
        }
        return "var window = this; \(string)"
    }()
    
    private lazy var context: JSContext? = {
        let context = JSContext()
        
        guard let context = context else {
            return nil
        }
        
        context.exceptionHandler = self.handleException
        
        TimerJS.registerInto(jsContext: context)
        
        _ = context.evaluateScript(script)
        
        return context
    }()
    
    private func handleException(_ context: JSContext?, _ value: JSValue?) -> Void {
        print("Exception: \(value.debugDescription)")
    }
    
    public func parseArticle(html: String) -> Result<Article, ReadabilityError> {
        guard let context = context,
              let function = context.objectForKeyedSubscript("parseArticle")
        else {
            return .failure(.jsContextError)
        }
            
        let result = function.call(withArguments: [html])
//
        guard let result = result, !result.isNull, result.isObject else {
            return .failure(.invalidResult(result))
        }

        let article = Article(from: result.toDictionary())
        return .success(article)
    }
}

