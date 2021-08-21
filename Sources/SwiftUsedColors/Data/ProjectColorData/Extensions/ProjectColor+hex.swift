//
//  ProjectColor+hex.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor.ColorRepresentation {
    
    /// Hex representation
    func hex(isLightMode: Bool) -> String? {
        switch self {
        case .system(let name, _):
            guard let light = ProjectColor.ColorRepresentation.lightSystemHex[name],
               let dark = ProjectColor.ColorRepresentation.darkSystemsHex[name]
            else {
                return nil
            }
            return isLightMode ? light : dark
            
        case .custom(let color):
            return color.hex
            
        case .asset(let color):
            switch color {
            case .any(let anyColor):
                return anyColor.hex
                
            case .anyDark(let light, let dark):
                switch (light, dark) {
                case (.rgb, .rgb):
                    return isLightMode ? light.hex : dark.hex
                
                default:
                    return nil
                }
            }
        }
    }
    
    private static var lightSystemHex: [String: String] = [
        "groupedCellBackgroundColor": "#ffffffff",
        "backwardCompatibilityLabel": "#000000ff",
        "gray": "#7f7f7fff",
        "whiteColor": "#ffffffff",
        "white": "#ffffffff",
        "tableCellGroupedBackgroundColor": "#c6c6c8ff",
        "darkTextColor": "#000000ff",
        "scrollViewTexturedBackgroundColor": "#6f7178ff",
        "black": "#000000ff",
        "label": "#000000ff",
        "secondaryLabel": "#3c3c4399",
        "tertiaryLabel": "#3c3c434c",
        "quaternaryLabel": "#3c3c432d",
        "systemFill": "#78788033",
        "secondarySystemFill": "#78788028",
        "tertiarySystemFill": "#7676801e",
        "quaternarySystemFill": "#74748014",
        "placeholderText": "#3c3c434c",
        "systemBackground": "#ffffffff",
        "secondarySystemBackground": "#f2f2f7ff",
        "tertiarySystemBackground": "#ffffffff",
        "systemGroupedBackground": "#f2f2f7ff",
        "secondarySystemGroupedBackground": "#ffffffff",
        "tertiarySystemGroupedBackground": "#f2f2f7ff",
        "separator": "#3c3c4349",
        "opaqueSeparator": "#c6c6c8ff",
        "link": "#007affff",
        "darkText": "#000000ff",
        "lightText": "#ffffff99",
        "systemBlue": "#007affff",
        "systemGreen": "#34c759ff",
        "systemIndigo": "#5856d6ff",
        "systemOrange": "#ff9500ff",
        "systemPink": "#ff2d55ff",
        "systemPurple": "#af52deff",
        "systemRed": "#ff3b30ff",
        "systemTeal": "#5ac8faff",
        "systemYellow": "#ffcc00ff",
        "systemGray": "#8e8e93ff",
        "systemGray2": "#aeaeb2ff",
        "systemGray3": "#c7c7ccff",
        "systemGray4": "#d1d1d6ff",
        "systemGray5": "#e5e5eaff",
        "systemGray6": "#f2f2f7ff",
    ]
    
    private static var darkSystemsHex: [String: String] = [
        "groupedCellBackgroundColor": "#1c1c1eff",
        "backwardCompatibilityLabel": "#ffffffff",
        "gray": "#7f7f7fff",
        "whiteColor": "#ffffffff",
        "white": "#ffffffff",
        "tableCellGroupedBackgroundColor": "#c6c6c8ff",
        "darkTextColor": "#ffffffff",
        "scrollViewTexturedBackgroundColor": "#6f7178ff",
        "black": "#000000ff",
        "label": "#ffffffff",
        "secondaryLabel": "#ebebf599",
        "tertiaryLabel": "#ebebf54c",
        "quaternaryLabel": "#ebebf52d",
        "systemFill": "#7878805b",
        "secondarySystemFill": "#78788051",
        "tertiarySystemFill": "#7676803d",
        "quaternarySystemFill": "#7676802d",
        "placeholderText": "#ebebf54c",
        "systemBackground": "#000000ff",
        "secondarySystemBackground": "#1c1c1eff",
        "tertiarySystemBackground": "#2c2c2eff",
        "systemGroupedBackground": "#000000ff",
        "secondarySystemGroupedBackground": "#1c1c1eff",
        "tertiarySystemGroupedBackground": "#2c2c2eff",
        "separator": "#54545899",
        "opaqueSeparator": "#38383aff",
        "link": "#0984ffff",
        "darkText": "#000000ff",
        "lightText": "#ffffff99",
        "systemBlue": "#0a84ffff",
        "systemGreen": "#30d158ff",
        "systemIndigo": "#5e5ce6ff",
        "systemOrange": "#ff9f0aff",
        "systemPink": "#ff375fff",
        "systemPurple": "#bf5af2ff",
        "systemRed": "#ff453aff",
        "systemTeal": "#64d2ffff",
        "systemYellow": "#ffd60aff",
        "systemGray": "#8e8e93ff",
        "systemGray2": "#636366ff",
        "systemGray3": "#48484aff",
        "systemGray4": "#3a3a3cff",
        "systemGray5": "#2c2c2eff",
        "systemGray6": "#1c1c1eff",
    ]
}

extension ProjectColor.Color {
    var hex: String? {
        switch self {
        case .rgb(let red, let green, let blue, let alpha):
            return String(
                format: "#%02X%02X%02X %.02f",
                UInt8(red * 255),
                UInt8(green * 255),
                UInt8(blue * 255),
                alpha
            )
            
        case .grayGamma(let white, let alpha):
            return String(
                format: "#%02X%02X%02X %.02f",
                UInt8(white * 255),
                UInt8(white * 255),
                UInt8(white * 255),
                alpha
            )
        }
    }
}
