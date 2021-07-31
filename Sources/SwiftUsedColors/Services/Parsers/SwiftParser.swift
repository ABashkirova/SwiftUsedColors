//
//  SwiftParser.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import SwiftSyntax
import PathKit

typealias ColorRegister = (ExploreUsage) -> ()

class SwiftParser {
    @discardableResult
    init(_ path: Path, _ register: @escaping ColorRegister) throws {
        let source = try SyntaxParser.parse(path.url)
        SourceVisitor(path.url, source, register)
    }
}
