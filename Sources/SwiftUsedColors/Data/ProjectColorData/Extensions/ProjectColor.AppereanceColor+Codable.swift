//
//  ProjectColor.AppereanceColor+Codable.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor.AppereanceColor {
    private enum CodingKeys: String, CodingKey {
        case any
        case anyDark
    }
    
    private struct AnyDark: Codable {
        let light: ProjectColor.Color
        let dark: ProjectColor.Color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        if let any = try? container.decode(ProjectColor.Color.self, forKey: .any) {
            self = .any(color: any)
        }
        else {
            let anyDark = try container.decode(AnyDark.self, forKey: .anyDark)
            self = .anyDark(light: anyDark.light, dark: anyDark.dark)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .any(let color):
            try container.encode(color, forKey: .any)
            
        case .anyDark(let light, let dark):
            try container.encode(AnyDark(light: light, dark: dark), forKey: .anyDark)
        }
    }
}
