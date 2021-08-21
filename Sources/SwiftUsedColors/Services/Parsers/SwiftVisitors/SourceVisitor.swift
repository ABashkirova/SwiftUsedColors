//
//  SourceVisitor.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import SwiftSyntax

class SourceVisitor: SyntaxVisitor {
    private let url: URL
    private let register: ColorRegister
    private var hasUIKit = false
    private var hasBonMot = false
    private var hasSwiftUI = false
    
    @discardableResult
    init(_ url: URL, _ node: SourceFileSyntax, _ register: @escaping ColorRegister) {
        self.url = url
        self.register = register
        super.init()
        walk(node)
    }

    override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let imp = node.path.firstToken?.text
        
        if (imp == "UIKit" || imp == "WatchKit") {
            hasUIKit = true
        }
        if (imp == "BonMot") {
            hasBonMot = true
        }
        else if (imp == "SwiftUI") {
            hasSwiftUI = true
        }

        return .skipChildren
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        FuncCallVisitor(url, node, register, uiKit: hasUIKit, bonMot: hasBonMot, swiftUI: hasSwiftUI)

        return super.visit(node)
    }
    
    override func visit(_ node: ObjectLiteralExprSyntax) -> SyntaxVisitorContinueKind {
        if (node.identifier.text != "#colorLiteral") {
            return .skipChildren
        }

        ColorLiteralVisitor(node, url: url, register)

        return .skipChildren
    }
}
