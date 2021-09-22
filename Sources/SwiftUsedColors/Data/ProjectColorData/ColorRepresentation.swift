//
//  ProjectColorData.ColorRepresentation.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum ColorRepresentation: Codable {
        case asset(color: AppearanceColor)
        case custom(color: Color)
        case system(name: String, alpha: Float = 1)
        
        var raw: String? {
            switch self {
            case .system: return nil
            case .custom(let color): return color.raw
            case .asset(let appearanceColor): return appearanceColor.raw
            }
        }
    }
}
