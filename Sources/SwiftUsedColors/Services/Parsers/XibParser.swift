//
//  XibParser.swift
//  
//  https://github.com/mugabe/SwiftUnusedResources
//  Created by mugabe.
//

import Foundation
import IBDecodable
import PathKit

enum XibParserError: Error {
    case wrongExtension
}

class XibParser {
    @discardableResult
    init(_ path: Path, _ register: @escaping ColorRegister) throws {
        let colors: [Color]?
        
        if (path.extension == "xib") {
            let file = try XibFile(url: path.url)
            colors = file.colors
        }
        else if (path.extension == "storyboard") {
            let file = try StoryboardFile(url: path.url)
            colors = file.colors
        }
        else {
            throw XibParserError.wrongExtension
        }

        colors?.forEach { color in
            var colorName: String
            switch color {
            case .name((_, let name)):
                colorName = name
                    
            case .systemColor((_, let name)):
                colorName = name
                
            default:
                let formatNameColor = Color.Format.rgbHexadecimal.representation(of: color)
                colorName = path.lastComponentWithoutExtension + (formatNameColor ?? "")
            }
            
            register(
                .xib(
                    XibColorSet(
                        name: colorName,
                        path: path,
                        color: color.xibColor
                    )
                )
            )
        }
    }
}

private extension Color {
    var xibColor: XibColorSet.Color {
        switch self {
        case .name(let name): return .named(name: name.name)
        case .systemColor(let name): return .system(name: name.name)
        case .calibratedRGB(let color): return .components(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        case .sRGB(let color): return .components(red: color.red, green: color.green, blue: color.blue, alpha: color.alpha)
        case .calibratedWhite(let color): return .grayGamma(white: color.white, alpha: color.alpha)
        }
    }
}
