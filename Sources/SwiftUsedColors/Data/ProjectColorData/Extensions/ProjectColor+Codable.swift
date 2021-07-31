//
//  ProjectColor+Codable.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation
import PathKit

extension ProjectColor {
    private enum CodingKeys: String, CodingKey {
        case colorRepresentation
        case names
        case files
        case hex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let colorRepresentation = try container.decode(ProjectColor.ColorRepresentation?.self, forKey: .colorRepresentation)
        let names = try container.decode([String]?.self, forKey: .names)
        let paths = try container.decode([String].self, forKey: .files)
        let usedInFiles: [Path] = paths.compactMap { Path($0) }
        self = ProjectColor(colorRepresentation: colorRepresentation, names: names, usedInFiles: usedInFiles)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let colorRepresentation = colorRepresentation {
            try container.encode(colorRepresentation, forKey: .colorRepresentation)
            if let names = names {
                try container.encode(names, forKey: .names)
            }
            if let usedInFiles = usedInFiles {
                try container.encode(usedInFiles.map { $0.lastComponent } , forKey: .files)
            }
            if let hex = hex {
                try container.encode(hex, forKey: .hex)
            }
        }
    }
}
