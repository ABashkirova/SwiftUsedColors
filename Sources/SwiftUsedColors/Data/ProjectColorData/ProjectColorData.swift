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
    func hex(isLightMode: Bool) -> String? {
        colorRepresentation?.hex(isLightMode: isLightMode)
    }
    
    /// Contains in Asset directory
    var isAsset: Bool {
        usedInFiles?.contains(where: { $0.extension == "colorset" }) ?? false
    }
    
    /// Found in code
    var isUsedInCode: Bool {
        !isAsset && usedInFiles?.contains(where: { $0.extension == "swift" }) ?? false
    }
    
    /// Found in layout
    var isUsedInXib: Bool {
        return !isAsset && usedInFiles?.contains(where: { $0.extension == "xib" }) ?? false
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
