//
//  StringVisitor.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import SwiftSyntax

class StringVisitor: SyntaxVisitor {
    var value: String = ""

    init(_ node: SyntaxProtocol) {
        super.init()
        node.children.forEach { syntax in
            walk(syntax)
        }
    }
    
    func parse() -> String {
        return value
    }
    
    override func visit(_ node: StringSegmentSyntax) -> SyntaxVisitorContinueKind {
        value += node.content.text
        return .skipChildren
    }
    
    override func visit(_ node: TupleExprElementSyntax) -> SyntaxVisitorContinueKind {
        value += StringVisitor(node).parse()
        return .skipChildren
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        value += ".*"
        return .skipChildren
    }
    
    override func visit(_ node: IdentifierExprSyntax) -> SyntaxVisitorContinueKind {
        value += ".*"
        return .skipChildren
    }
    
    override func visit(_ node: SubscriptExprSyntax) -> SyntaxVisitorContinueKind {
        value += ".*"
        return .skipChildren
    }
    
    override func visit(_ node: TernaryExprSyntax) -> SyntaxVisitorContinueKind {
        let first = StringVisitor(node.firstChoice).parse()
        let second = StringVisitor(node.secondChoice).parse()
        
        if (first == ".*" || second == ".*") {
            value += ".*"
            return .skipChildren
        }
        
        if (first == "" && second != "") {
            value += "(?:\(second))?"
            return .skipChildren
        }
        
        if (first != "" && second == "") {
            value += "(?:\(first))?"
            return .skipChildren
        }
        
        value += "(?:\(first)|\(second))"
        
        return .skipChildren
    }
}
