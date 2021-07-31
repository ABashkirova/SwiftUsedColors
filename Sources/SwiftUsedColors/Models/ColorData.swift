//
//  ColorData.swift
//  
//
//  Created by Alexandra Bashkirova on 29.07.2021.
//

import Foundation

struct ColorData {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    init(
        red: Double = 0.0,
        green: Double = 0.0,
        blue: Double = 0.0,
        alpha: Double = 0.0
    ) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    var hexName: String {
        let redValue = Int(round(255 * red))
        let greenValue = Int(round(255 * green))
        let blueValue = Int(round(255 * blue))
        let alphaValue = alpha
        
        let hexRed = String(format: "%2X", redValue)
            .replacingOccurrences(of: " ", with: "0")
        let hexGreen = String(format: "%2X", greenValue)
            .replacingOccurrences(of: " ", with: "0")
        let hexBlue = String(format: "%2X", blueValue)
            .replacingOccurrences(of: " ", with: "0")
        return "\(hexRed)\(hexGreen)\(hexBlue) (alpha \(alphaValue))"
    }
    
    static func == (lhs: ColorData, rhs: ColorData) -> Bool {
        return fabs(lhs.red - rhs.red) < Double.ulpOfOne &&
               fabs(lhs.green - rhs.green) < Double.ulpOfOne &&
               fabs(lhs.blue - rhs.blue) < Double.ulpOfOne &&
               fabs(lhs.alpha - rhs.alpha) < Double.ulpOfOne
    }
    
    var hashValue: Int {
        return (red + blue + green + alpha).hashValue
    }
}

extension ColorData {
    var projectColor: ProjectColor.Color {
        return .rgb(
            red: Float(red),
            green: Float(green),
            blue: Float(blue),
            alpha: Float(alpha)
        )
    }
}
