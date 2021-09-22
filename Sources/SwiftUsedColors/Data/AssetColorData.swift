//
//  AssetColorData.swift
//
//
//  Created by Alexandra Bashkirova on 29.07.2021.
//

import Foundation

struct AssetColorData: Codable {
    let colors: [Element]
}

extension AssetColorData {
    struct Element: Codable {
        var color: Color?
        var appearances: [AppearanceData]?
    }
}

extension AssetColorData.Element {
    struct Color: Codable {
        let colorSpace: ColorSpace
        let components: Components
    }
    
    struct AppearanceData: Codable {
        var appearance: Appearance
        var value: Value
        
        enum Appearance: String, Codable {
            case luminosity
            case contrast
        }
        
        enum Value: String, Codable {
            case light
            case dark
            case high
        }
    }
}

extension AssetColorData.Element.Color {
    
    enum Components: Codable {
        case gray(white: String, alpha: String)
        case rgb(red: String, green: String, blue: String, alpha: String)
        
        var raw: String {
            switch self {
            case .gray(let white, let alpha):
                return "GrayGamma(white: \(white), \(alpha))"
            case .rgb(let r, let g, let b, let a):
                return "RGB(r: \(r), g: \(g), b: \(b), a: \(a))"
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case white
            case red
            case green
            case blue
            case alpha
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let alpha = try container.decode(String.self, forKey: .alpha)
            
            if let white = try? container.decode(String.self, forKey: .white) {
                self = .gray(white: white, alpha: alpha)
            }
            else {
                let red = try container.decode(String.self, forKey: .red)
                let green = try container.decode(String.self, forKey: .green)
                let blue = try container.decode(String.self, forKey: .blue)
                self = .rgb(red: red, green: green, blue: blue, alpha: alpha)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .gray(let white, let alpha):
                try container.encode(white, forKey: .white)
                try container.encode(alpha, forKey: .alpha)
                
            case .rgb(let red, let green, let blue, let alpha):
                try container.encode(red, forKey: .red)
                try container.encode(green, forKey: .green)
                try container.encode(blue, forKey: .blue)
                try container.encode(alpha, forKey: .alpha)
            }
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case colorSpace = "color-space"
        case components
    }
    
    enum ColorSpace: String, Codable  {
        case srgb = "srgb"
        case extendedSRGB = "extended-srgb"
        case extendedLinearSRGB = "extended-linear-srgb"
        
        case displayP3 = "display-p3"
        
        case grayGamma22 = "gray-gamma-22"
        case extendedGray = "extended-gray"
    }
    
}
