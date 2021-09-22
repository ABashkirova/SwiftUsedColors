//
//  ProjectColorData.AppearanceColor.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum AppearanceColor: Codable {
        case any(color: Color)
        case anyDark(light: Color, dark: Color)
        
        var raw: String? {
            switch self {
            case .any(let color): return color.raw
            case .anyDark(let light, let dark):
                var raws: [String] = []
                if let lightRaw = light.raw {
                    raws.append("LightMode: \(lightRaw)")
                }
                if let darkRaw = dark.raw {
                    raws.append("DarkMode: \(darkRaw)")
                }
                return raws.isEmpty ? nil : raws.joined(separator: ", ")
            }
        }
    }
}
