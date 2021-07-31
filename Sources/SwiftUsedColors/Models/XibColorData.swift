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
}

extension XibColorSet {
    enum Color {
        /// name of asset's color
        case named(name: String)
        /// name of system color
        case system(name: String)
        /// gray gamma color
        case grayGamma(white: Float, alpha: Float)
        // custom color
        case components(red: Float, green: Float, blue: Float, alpha: Float)
    }
}

extension XibColorSet {
    var projectColor: ProjectColor? {
        switch color {
        case .components(let red, let green, let blue, let alpha):
            return ProjectColor(
                colorRepresentation: .custom(color: .rgb(red: red, green: green, blue: blue, alpha: alpha)),
                names: [name],
                usedInFiles: [path]
            )
            
        case .grayGamma(let white, let alpha):
            return ProjectColor(
                colorRepresentation: .custom(color: .grayGamma(white: white, alpha: alpha)),
                names: [name],
                usedInFiles: [path]
            )
            
        case .system(let colorName):
            return ProjectColor(
                colorRepresentation: .system(name: colorName),
                names: [name],
                usedInFiles: [path]
            )
            
        case .named:
            return nil
            
        }
    }
}
