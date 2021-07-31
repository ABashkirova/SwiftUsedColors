//
//  ColorLiteralVisitor.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import SwiftSyntax

class ColorLiteralVisitor: SyntaxVisitor {
    private let register: ColorRegister
    private let url: URL
    
    @discardableResult
    init(_ node: ObjectLiteralExprSyntax, url: URL, _ register: @escaping ColorRegister) {
        self.register = register
        self.url = url
        super.init()
        
        walk(node)
    }
    
    override func visit(_ node: TupleExprElementSyntax) -> SyntaxVisitorContinueKind {
        if (node.label?.text != "resourceName") {
            return .skipChildren
        }
        
        register(.string(StringVisitor(node.expression).parse(), path: url))
        
        return .skipChildren
    }
}

