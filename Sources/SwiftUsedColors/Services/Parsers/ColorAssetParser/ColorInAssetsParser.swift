//
//  ColorInAssetsParser.swift
//  
//
//  Created by Alexandra Bashkirova on 29.07.2021.
//

import Foundation
import AppKit
import PathKit

typealias ColorSetRegister = (ColorSet) -> ()

class ColorInAssetsParser {
    
    @discardableResult
    init(_ path: Path, _ register: @escaping ColorSetRegister) throws {
        guard path.extension == "colorset" else {
            return
        }
        
        guard
            let data = try path.children().first(where: { $0.lastComponent == "Contents.json" })?.read()
        else {
            return
        }
        
        let asset: AssetColorData = try! JSONDecoder().decode(AssetColorData.self, from: data)
        
        var colorsSet: [ColorAppearance : ColorData] = [:]
        
        guard !asset.colors.isEmpty else {
            return
        }
        
        asset.colors.forEach { element in
            let appearance = ColorAppearance(data: element.appearances)
            
            guard let color = element.color else {
                return
            }
            
            colorsSet[appearance] = convertAssetColorToSRGB(color: color)
        }
        
        register(
            ColorSet(
                name: path.lastComponentWithoutExtension,
                path: path,
                colors: colorsSet
            )
        )
    }
    
    // MARK: - Converters
    
    private func convertAssetColorToSRGB(color: AssetColorData.Element.Color) -> ColorData {
        switch color.colorSpace {
        case .srgb:
            return parseComponentsSRGB(components: color.components)
        
        case .extendedSRGB:
            return convertExtendedSRGB(components: color.components)
        
        case .extendedLinearSRGB:
            return convertExtendedLinearSRGB(components: color.components)
        
        case .displayP3:
            return convertDisplayP3(components: color.components)
        
        case .grayGamma22:
            return convertGrayGamma22(components: color.components)
        
        case .extendedGray:
            return convertExtendedGray(components: color.components)
        }
    }
    
    private func parseComponentsSRGB(components: AssetColorData.Element.Color.Components) -> ColorData {
        var colorData = ColorData()
        guard case .rgb(let red, let green, let blue, let alpha) = components else {
            return colorData
        }
        
        if red.contains(".") { // Example: 0.0 -> 1.0
            colorData.red = Double(red) ?? 0
            colorData.green = Double(green) ?? 0
            colorData.blue = Double(blue) ?? 0
        }
        else if red.contains("") { // Example: 0x00 -> 0xFF
            colorData.red = Double(Int(red.suffix(2), radix: 16) ?? 0) / 255
            colorData.green = Double(Int(green.suffix(2), radix: 16) ?? 0) / 255
            colorData.blue = Double(Int(blue.suffix(2), radix: 16) ?? 0) / 255
        }
        else { // 0 -> 255
            colorData.red = (Double(red) ?? 0.0) / 255
            colorData.green = (Double(green) ?? 0.0) / 255
            colorData.blue = (Double(blue) ?? 0.0) / 255
        }
        colorData.alpha = Double(alpha) ?? 0
        
        return colorData
    }
    
    private func convertExtendedSRGB(components: AssetColorData.Element.Color.Components) -> ColorData {
        let colorData = ColorData()
        guard case .rgb(let cRed, let cGreen, let cBlue, let cAlpha) = components else {
            return colorData
        }
        
        let red = CGFloat(Double(cRed) ?? 0.0)
        let green = CGFloat(Double(cGreen) ?? 0.0)
        let blue = CGFloat(Double(cBlue) ?? 0.0)
        let alpha = CGFloat(Double(cAlpha) ?? 0.0)
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(
                    colorSpace: .extendedSRGB,
                    components: [red, green, blue, alpha],
                    count: 4
                )
                .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            let correctedComponents: AssetColorData.Element.Color.Components =
                .rgb(
                    red: String(describing: color.redComponent),
                    green: String(describing: color.greenComponent),
                    blue: String(describing: color.blueComponent),
                    alpha: String(describing: color.alphaComponent)
                )
            
            return parseComponentsSRGB(components: correctedComponents)
        }
        
        return colorData
    }
    
    private func convertExtendedLinearSRGB(components: AssetColorData.Element.Color.Components) -> ColorData {
        let colorData = ColorData()
        guard case .rgb(let cRed, let cGreen, let cBlue, let cAlpha) = components else {
            return colorData
        }
        
        let red = CGFloat(Double(cRed) ?? 0.0)
        let green = CGFloat(Double(cGreen) ?? 0.0)
        let blue = CGFloat(Double(cBlue) ?? 0.0)
        let alpha = CGFloat(Double(cAlpha) ?? 0.0)
        
        if #available(OSX 10.12, *) {
            guard
                let extendedLinearSRGBColorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
            else {
                return colorData
            }
            
            guard let sRGBColorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
                return colorData
            }
            
            guard
                let cgColor = CGColor(
                    colorSpace: extendedLinearSRGBColorSpace,
                    components: [red, green, blue, alpha]
                )
            else {
                return colorData
            }
            
            guard
                let correctedCGColor = cgColor.converted(
                    to: sRGBColorSpace,
                    intent: .defaultIntent,
                    options: nil
                )
            else {
                return colorData
            }
            
            guard let color = NSColor(cgColor: correctedCGColor) else {
                return colorData
            }
            
            let correctedComponents: AssetColorData.Element.Color.Components =
                .rgb(
                    red: String(describing: color.redComponent),
                    green: String(describing: color.greenComponent),
                    blue: String(describing: color.blueComponent),
                    alpha: String(describing: color.alphaComponent)
                )
            
            return parseComponentsSRGB(components: correctedComponents)
        }
        
        return colorData
    }
    
    private func convertDisplayP3(components: AssetColorData.Element.Color.Components) -> ColorData {
        let colorData = ColorData()
        guard case .rgb(let cRed, let cGreen, let cBlue, let cAlpha) = components else {
            return colorData
        }
        
        let red = CGFloat(Double(cRed) ?? 0.0)
        let green = CGFloat(Double(cGreen) ?? 0.0)
        let blue = CGFloat(Double(cBlue) ?? 0.0)
        let alpha = CGFloat(Double(cAlpha) ?? 0.0)
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
                                .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            let correctedComponents: AssetColorData.Element.Color.Components =
                .rgb(
                    red: String(describing: color.redComponent),
                    green: String(describing: color.greenComponent),
                    blue: String(describing: color.blueComponent),
                    alpha: String(describing: color.alphaComponent)
                )
            
            return parseComponentsSRGB(components: correctedComponents)
        }
        
        return colorData
    }
    
    private func convertGrayGamma22(components: AssetColorData.Element.Color.Components) -> ColorData {
        let colorData = ColorData()
        guard case .gray(let cWhite, let cAlpha) = components else {
            return colorData
        }
        
        let white = CGFloat(Double(cWhite) ?? 0.0)
        let alpha = CGFloat(Double(cAlpha) ?? 0.0)
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(genericGamma22White: white, alpha: alpha)
                    .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            let correctedComponents: AssetColorData.Element.Color.Components =
                .rgb(
                    red: String(describing: color.redComponent),
                    green: String(describing: color.greenComponent),
                    blue: String(describing: color.blueComponent),
                    alpha: String(describing: color.alphaComponent)
                )
            
            return parseComponentsSRGB(components: correctedComponents)
        }
        
        return colorData
    }
    
    private func convertExtendedGray(components: AssetColorData.Element.Color.Components) -> ColorData {
        let colorData = ColorData()

        guard case .gray(let cWhite, let cAlpha) = components else {
            return colorData
        }
        
        let white = CGFloat(Double(cWhite) ?? 0.0)
        let alpha = CGFloat(Double(cAlpha) ?? 0.0)
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(colorSpace: .extendedGenericGamma22Gray, components: [white, alpha], count: 2)
                                .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            let correctedComponents: AssetColorData.Element.Color.Components =
                .rgb(
                    red: String(describing: color.redComponent),
                    green: String(describing: color.greenComponent),
                    blue: String(describing: color.blueComponent),
                    alpha: String(describing: color.alphaComponent)
                )
            
            return parseComponentsSRGB(components: correctedComponents)
        }
        
        return colorData
    }

}
