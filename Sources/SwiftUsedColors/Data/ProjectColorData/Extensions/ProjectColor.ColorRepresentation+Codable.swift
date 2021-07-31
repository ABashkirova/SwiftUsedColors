//
//  ProjectColor.ColorRepresentation+Codable.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor.ColorRepresentation {
    private enum CodingKeys: String, CodingKey {
        case asset
        case custom
        case system
    }
    
    private struct Custom: Codable {
        let color: ProjectColor.Color
    }
    
    private struct System: Codable {
        let name: String
        let alpha: Float
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        if let asset = try? container.decode(ProjectColor.AppereanceColor.self, forKey: .asset) {
            self = .asset(color: asset)
        }
        else if let custom = try? container.decode(Custom.self, forKey: .custom) {
            self = .custom(color: custom.color)
        }
        else {
            let system = try container.decode(System.self, forKey: .system)
            self = .system(name: system.name)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .asset(let color):
            try container.encode(color, forKey: .asset)
            
        case .custom(let color):
            try container.encode(Custom(color: color), forKey: .custom)
        
        case .system(let name, let alpha):
            try container.encode(System(name: name, alpha: alpha), forKey: .system)
        }
    }
}
