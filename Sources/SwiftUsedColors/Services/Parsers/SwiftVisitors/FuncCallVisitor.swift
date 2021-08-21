//
//  FuncCallVisitor.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import SwiftSyntax

class FuncCallVisitor: SyntaxVisitor {
    private let register: ColorRegister
    private let url: URL
    private var name: String?
    
    @discardableResult
    init(
        _ url: URL,
        _ node: FunctionCallExprSyntax,
        _ register: @escaping ColorRegister,
        uiKit: Bool,
        bonMot: Bool,
        swiftUI: Bool
    ) {
        self.register = register
        self.url = url
        
        super.init()
        
        walk(node.calledExpression)
        
        if (name == nil) {
            return
        }

        if (name == "UIColor") {
            if !uiKit && !bonMot {
                warn(url: url, node: node, "UIColor used but UIKit not imported")
            }
            
            if node.argumentList.contains(where: { $0.label?.text == "white" }) {
                guard let white = node.argumentList.first(where: { $0.label?.text == "white" }),
                      let alpha = node.argumentList.first(where: { $0.label?.text == "alpha" })
                else {
                    return
                }
                uiColorWithGrayGammaArguments(white: white, alpha: alpha)
            }
            if node.argumentList.contains(where: { $0.label?.text == "red" }) {
                guard let red = node.argumentList.first(where: { $0.label?.text == "red" }),
                      let green = node.argumentList.first(where: { $0.label?.text == "green" }),
                      let blue = node.argumentList.first(where: { $0.label?.text == "blue" })
                else {
                    return
                }
                uiColorRBGArguments(
                    red: red,
                    green: green,
                    blue: blue,
                    alpha: node.argumentList.first(where: { $0.label?.text == "alpha" })
                )
            }
            
            if let namedTuple = node.argumentList.first(where: { $0.label?.text == "named" }) {
                if let comment = findComment(namedTuple) {
                    register(.regexp(comment, path: url))
                    return
                }
                
                let regex = StringVisitor(namedTuple).parse()
                if (regex == ".*") {
                    warn(url: url, node: namedTuple, "Couldn't guess match, please specify pattern")
                    return
                }

                if (regex.contains("*")) {
                    warn(url: url, node: namedTuple, "Too wide match \"\(regex)\" is generated for resource, please specify pattern")
                }
                
                register(.regexp(regex, path: url))
            }
        }
        else if (name == "Color") {
            if (!swiftUI || !bonMot) {
                warn(url: url, node: node, "Color used but SwiftUI not imported")
            }
            if (node.argumentList.count != 1) {
                return
            }
            
            guard let tuple = node.argumentList.first else {
                return
            }
            
            if let comment = findComment(tuple) {
                register(.regexp(comment, path: url))
                return
            }
            
            let regex = StringVisitor(tuple).parse()

            if (regex == ".*") {
                warn(url: url, node: tuple, "Couldn't guess match, please specify pattern")
                return
            }

            if (regex.contains("*")) {
                warn(url: url, node: tuple, "Too wide match \"\(regex)\" is generated for resource, please specify pattern")
            }

            register(.regexp(regex, path: url))
        }
    }

    private func warn(url: URL, node: SyntaxProtocol, _ message: String) {
        guard showWarnings else {
            return
        }
            
        let source = String(String(describing: node.root).prefix(node.position.utf8Offset))
        let line = source.count(of: "\n") + 1
        let pos = source.distance(from: source.lastIndex(of: "\n") ?? source.endIndex, to: source.endIndex)

        print("\(url.path):\(line):\(pos): warning: \(message)")
    }
    
    private func matchComment(text: String) -> String? {
        guard
            let regex = try? NSRegularExpression(pattern: "^\\s*(?:\\/\\/\\/|\\*+)?\\s*color:\\s*(.*?)\\s*$"),
            let match = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text)),
            let range = Range(match.range(at: 1), in: text)
        else {
            return nil
        }

        return String(text[range])
    }
    
    private func extractComment(_ trivia: Trivia?) -> String? {
        guard let trivia = trivia else {
            return nil
        }
        
        for piece in trivia {
            if case .docLineComment(let c) = piece {
                if let c = self.matchComment(text: c) {
                    return c
                }
            }
            else if case .docBlockComment(let c) = piece {
                if let c = self.matchComment(text: c) {
                    return c
                }
            }
        }
        
        return nil
    }
    
    private func findComment(_ node: SyntaxProtocol) -> String? {
        var p: SyntaxProtocol = node

        while (p.parent != nil && p.syntaxNodeType != CodeBlockItemSyntax.self) {
            if let comment = extractComment(p.leadingTrivia) {
                return comment
            }

            p = p.parent!
        }
        
        return nil
    }
    
    override func visit(_ node: IdentifierExprSyntax) -> SyntaxVisitorContinueKind {
        name = node.identifier.text
        
        return .skipChildren
    }
    
    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        if
            let baseColor = node.base?.as(MemberAccessExprSyntax.self),
            baseColor.name.text == "color",
            let baseR = baseColor.base?.as(IdentifierExprSyntax.self),
            baseR.identifier.text == "R"
        {
            let name = node.name.text
            
            register(.rswift(name, path: url))
        }
        else if
            let baseColorClass = node.base?.as(IdentifierExprSyntax.self),
            baseColorClass.identifier.text == "UIColor" || baseColorClass.identifier.text == "Color"
        {
            let name = node.name.text
            
            register(.system(name, alpha: 1, path: url))
        }
        else if
            node.name.text == "withAlphaComponent",
            let baseColorName = node.base?.as(MemberAccessExprSyntax.self),
            let baseColorClass = baseColorName.base?.as(IdentifierExprSyntax.self),
            baseColorClass.identifier.text == "UIColor"
        {
            let name = baseColorName.name.text
            if let alphaRawValue = node.nextToken?.nextToken?.text, let alpha = Float(alphaRawValue) {
                register(.system(name, alpha: alpha, path: url))
            }
            else {
                register(.system(name, alpha: 1, path: url))
            }
        }
        else if
            node.name.text == "opacity",
            let baseColorName = node.base?.as(MemberAccessExprSyntax.self),
            let baseColorClass = baseColorName.base?.as(IdentifierExprSyntax.self),
            baseColorClass.identifier.text == "Color"
        {
            let name = baseColorName.name.text
            if let alphaRawValue = node.nextToken?.nextToken?.text, let alpha = Float(alphaRawValue) {
                register(.system(name, alpha: alpha, path: url))
            }
            else {
                register(.system(name, alpha: 1, path: url))
            }
        }

        return .skipChildren
    }
    
    /// TODO: refactor need expression visitor
    private func uiColorRBGArguments(
        red: TupleExprElementListSyntax.Element,
        green: TupleExprElementListSyntax.Element,
        blue: TupleExprElementListSyntax.Element,
        alpha: TupleExprElementListSyntax.Element?
    ) {
        if
            let redRawValue = red.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let r = Float(redRawValue),
            let greenRawValue = green.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let g = Float(greenRawValue),
            let blueRawValue = green.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let b = Float(blueRawValue)
        {
            if
                let alpha = alpha,
                let alphaRowValue = alpha.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text,
                let alphaValue = Float(alphaRowValue)
            {
                register(.rgb(red: r / 255, green: g / 255, blue: b / 255, alpha: alphaValue, path: url))
            }
            else {
                register(.rgb(red: r / 255, green: g / 255, blue: b / 255, alpha: 1, path: url))
            }
            
            return
        }
        else {
            print(red)
        }
    }
    
    /// TODO: refactor need expression visitor
    private func uiColorWithGrayGammaArguments(
        white: TupleExprElementListSyntax.Element,
        alpha: TupleExprElementListSyntax.Element
    ) {
        if
            let whiteRawValue = white.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let whiteValue = Float(whiteRawValue),
            let alphaRawValue = alpha.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let alphaValue = Float(alphaRawValue)
        {
            register(.grayGamma(white: whiteValue / 255, alpha: alphaValue, path: url))
            return
        }
        
        if
            let whiteRawValue = white.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text,
            let whiteValue = Float(whiteRawValue),
            let alphaRawValue = alpha.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text,
            let alphaValue = Float(alphaRawValue)
        {
            register(.grayGamma(white: whiteValue, alpha: alphaValue, path: url))
            return
        }
        if
            let whiteRawValue = white.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let whiteValue = Float(whiteRawValue),
            let alphaRawValue = alpha.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text,
            let alphaValue = Float(alphaRawValue)
        {
            register(.grayGamma(white: whiteValue / 255, alpha: alphaValue, path: url))
            return
        }
        
        if
            let whiteRawValue = white.expression.as(FloatLiteralExprSyntax.self)?.floatingDigits.text,
            let whiteValue = Float(whiteRawValue),
            let alphaRawValue = alpha.expression.as(IntegerLiteralExprSyntax.self)?.digits.text,
            let alphaValue = Float(alphaRawValue)
        {
            register(.grayGamma(white: whiteValue, alpha: alphaValue, path: url))
            return
        }
    }
}
