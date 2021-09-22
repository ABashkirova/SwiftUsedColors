//
//  ProjectColor.Color+Codable.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor.Color {
    private enum CodingKeys: String, CodingKey {
        case white
        case red
        case green
        case blue
        case alpha
        case raw
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let alpha = try container.decode(Float.self, forKey: .alpha)
        let raw = try container.decode(String?.self, forKey: .raw)
        
        if let white = try? container.decode(Float.self, forKey: .white) {
            self = .rgb(red: white, green: white, blue: white, alpha: alpha, raw: raw)
        }
        else {
            let red = try container.decode(Float.self, forKey: .red)
            let green = try container.decode(Float.self, forKey: .green)
            let blue = try container.decode(Float.self, forKey: .blue)
            self = .rgb(red: red, green: green, blue: blue, alpha: alpha, raw: raw)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .grayGamma(let white, let alpha, let raw):
            try container.encode(white, forKey: .red)
            try container.encode(white, forKey: .green)
            try container.encode(white, forKey: .blue)
            try container.encode(alpha, forKey: .alpha)
            try container.encode(raw, forKey: .raw)
            
        case .rgb(let red, let green, let blue, let alpha, let raw):
            try container.encode(red, forKey: .red)
            try container.encode(green, forKey: .green)
            try container.encode(blue, forKey: .blue)
            try container.encode(alpha, forKey: .alpha)
            try container.encode(raw, forKey: .raw)
        }
    }
}
