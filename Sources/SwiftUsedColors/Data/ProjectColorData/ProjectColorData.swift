//
//  File.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation
import PathKit

struct ProjectColor: Codable {
    /// Color: system/asset/custom
    let colorRepresentation: ColorRepresentation?
    
    /// Names of the color
    var names: [String]?
    
    /// Files in which the color was used
    var usedInFiles: [Path]?
    
    /// Hex representation
    var hex: String? {
        colorRepresentation?.hex
    }
    
    func equalColors(with color: ProjectColor) -> Bool {
        return colorRepresentation == color.colorRepresentation
    }
    
    mutating func merge(dublicate color: ProjectColor) {
        guard equalColors(with: color) else {
            return
        }
        
        let newNames = Set(names ?? []).union(color.names ?? [])
        let newPaths = Set(usedInFiles ?? []).union(color.usedInFiles ?? [])
        
        names = Array(newNames)
        usedInFiles = Array(newPaths)
    }
}
