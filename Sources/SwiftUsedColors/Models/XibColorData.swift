//
//  File.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation
import PathKit

struct XibColorSet {
    let name: String
    let path: Path
    let color: XibColorSet.Color
    
    var key: String? {
        color.key
    }
}

extension XibColorSet {
    enum Color {
        /// name of asset's color
        case named(name: String, key: String?)
        /// name of system color
        case system(name: String, key: String?)
        /// gray gamma color
        case grayGamma(white: Float, alpha: Float, key: String?)
        /// custom color
        case components(red: Float, green: Float, blue: Float, alpha: Float, key: String?)
        
        var key: String? {
            switch self {
            case
                .named(_, let key),
                .system(_, let key),
                .grayGamma(_, _, let key),
                .components(_, _, _, _, let key):
                return key
            }
        }
    }
}

extension XibColorSet {
    var projectColor: ProjectColor? {
        var keys: [String]?
        if let key = color.key {
            keys = [key]
        }
        switch color {
        case .components(let red, let green, let blue, let alpha, _):
            
            return ProjectColor(
                colorRepresentation: .custom(color: .rgb(red: red, green: green, blue: blue, alpha: alpha)),
                names: [name],
                usedInFiles: [path],
                keys: keys
            )
            
        case .grayGamma(let white, let alpha, _):
            return ProjectColor(
                colorRepresentation: .custom(color: .grayGamma(white: white, alpha: alpha)),
                names: [name],
                usedInFiles: [path],
                keys: keys
            )
            
        case .system(let colorName, _):
            return ProjectColor(
                colorRepresentation: .system(name: colorName),
                names: [name],
                usedInFiles: [path],
                keys: keys
            )
            
        case .named:
            return nil
            
        }
    }
}
