//
//  ProjectColorData.Color.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum Color: Codable {
        typealias HSV = (hue: Float, saturation: Float, value: Float)
        
        case rgb(red: Float, green: Float, blue: Float, alpha: Float, raw: String?)
        case grayGamma(white: Float, alpha: Float, raw: String?)
        
        var alpha: Double {
            switch self {
            case .rgb(_, _, _, let alpha, _), .grayGamma(_, let alpha, _):
                return Double(alpha)
            }
        }
        
        var raw: String? {
            switch self {
            case .rgb(_, _, _, _, let raw), .grayGamma(_, _, let raw):
                return raw
            }
        }
        
        var rgb: (r: Float, g: Float, b: Float) {
            switch self {
            case .grayGamma(let white, _, _):
                return (r: white, g: white, b: white)
            case .rgb(let red, let green, let blue, _, _):
                return (r: red, g: green, b: blue)
            }
        }
        
        var hsv: HSV {
            let rgb = rgb
            let min = min(min(rgb.r, rgb.g), rgb.b)
            let max = max(max(rgb.r, rgb.g), rgb.b)
            
            let saturation: Float = max.isZero ? 0 : 1 - min / max
            let value = max
            let hue: Float
            
            switch max {
            case min:
                hue = 0
            case rgb.r where rgb.g >= rgb.b:
                hue = 60 * (rgb.g - rgb.b) / (max - min)
            case rgb.r where rgb.g < rgb.b:
                hue = 60 * (rgb.g - rgb.b) / (max - min) + 360
            case rgb.g:
                hue = 60 * (rgb.b - rgb.r) / (max - min) + 120
            case rgb.b:
                hue = 60 * (rgb.r - rgb.g) / (max - min) + 240
            default:
                hue = 0
            }
            
            return (hue: hue, saturation: saturation, value: value)
        }
    }
}
