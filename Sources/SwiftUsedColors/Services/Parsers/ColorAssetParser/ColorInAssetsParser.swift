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
    
    private func convertAssetColorToSRGB(color: AssetColorData.Element.Color) -> ColorData? {
        switch color.colorSpace {
        case .srgb:
            return parseComponentRGB(components: color.components)
        
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
    
    private func parseComponentRGB(components: AssetColorData.Element.Color.Components) -> ColorData? {
        var colorData = ColorData()
        guard case .rgb(let red, let green, let blue, let alpha) = components else {
            print(AppError.processingFailed)
            return nil
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
        colorData.raw = components.raw
        return colorData
    }
    
    private func convertExtendedSRGB(components: AssetColorData.Element.Color.Components) -> ColorData? {
        guard var colorData = parseComponentRGB(components: components) else {
            print(AppError.processingFailed)
            return nil
        }
        
        let red = CGFloat(colorData.red)
        let green = CGFloat(colorData.green)
        let blue = CGFloat(colorData.blue)
        let alpha = CGFloat(colorData.alpha)
        
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
            
            colorData.red = Double(color.redComponent)
            colorData.blue = Double(color.blueComponent)
            colorData.green = Double(color.greenComponent)
            colorData.alpha = Double(color.alphaComponent)
        }
        
        return colorData
    }
    
    private func convertExtendedLinearSRGB(components: AssetColorData.Element.Color.Components) -> ColorData? {
        guard var colorData = parseComponentRGB(components: components) else {
            print(AppError.processingFailed)
            return nil
        }
        
        let red = CGFloat(colorData.red)
        let green = CGFloat(colorData.green)
        let blue = CGFloat(colorData.blue)
        let alpha = CGFloat(colorData.alpha)
        
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
            
            
            colorData.red = Double(color.redComponent)
            colorData.blue = Double(color.blueComponent)
            colorData.green = Double(color.greenComponent)
            colorData.alpha = Double(color.alphaComponent)
        }
        
        return colorData
    }
    
    private func convertDisplayP3(components: AssetColorData.Element.Color.Components) -> ColorData? {
        guard var colorData = parseComponentRGB(components: components) else {
            print(AppError.processingFailed)
            return nil
        }
        
        let red = CGFloat(colorData.red)
        let green = CGFloat(colorData.green)
        let blue = CGFloat(colorData.blue)
        let alpha = CGFloat(colorData.alpha)
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(displayP3Red: red, green: green, blue: blue, alpha: alpha)
                                .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            colorData.red = Double(color.redComponent)
            colorData.blue = Double(color.blueComponent)
            colorData.green = Double(color.greenComponent)
            colorData.alpha = Double(color.alphaComponent)
        }
        
        return colorData
    }
    
    private func convertGrayGamma22(components: AssetColorData.Element.Color.Components) -> ColorData? {
        var colorData = ColorData()
        guard case .gray(let cWhite, let cAlpha) = components else {
            return nil
        }
        let white: Double
        if cWhite.contains(".") { // Example: 0.0 -> 1.0
            white = Double(cWhite) ?? 0
        }
        else if cWhite.contains("") { // Example: 0x00 -> 0xFF
            white = Double(Int(cWhite.suffix(2), radix: 16) ?? 0) / 255
        }
        else { // 0 -> 255
            white = (Double(cWhite) ?? 0.0) / 255
        }
        let alpha = Double(cAlpha) ?? 0
        
        colorData.alpha = alpha
        colorData.red = white
        colorData.green = white
        colorData.blue = white
        colorData.raw = components.raw
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(genericGamma22White: CGFloat(white), alpha: CGFloat(alpha))
                    .usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            colorData.red = Double(color.redComponent)
            colorData.blue = Double(color.blueComponent)
            colorData.green = Double(color.greenComponent)
            colorData.alpha = Double(color.alphaComponent)
        }
        
        return colorData
    }
    
    private func convertExtendedGray(components: AssetColorData.Element.Color.Components) -> ColorData? {
        var colorData = ColorData()

        guard case .gray(let cWhite, let cAlpha) = components else {
            return nil
        }
        
        let white: Double
        if cWhite.contains(".") { // Example: 0.0 -> 1.0
            white = Double(cWhite) ?? 0
        }
        else if cWhite.contains("") { // Example: 0x00 -> 0xFF
            white = Double(Int(cWhite.suffix(2), radix: 16) ?? 0) / 255
        }
        else { // 0 -> 255
            white = (Double(cWhite) ?? 0.0) / 255
        }
        let alpha = Double(cAlpha) ?? 0
        
        colorData.alpha = alpha
        colorData.red = white
        colorData.green = white
        colorData.blue = white
        colorData.raw = components.raw
        
        if #available(OSX 10.12, *) {
            guard
                let color = NSColor(
                    colorSpace: .extendedGenericGamma22Gray,
                    components: [CGFloat(white), CGFloat(alpha)],
                    count: 2
                ).usingColorSpace(.sRGB)
            else {
                return colorData
            }
            
            colorData.red = Double(color.redComponent)
            colorData.blue = Double(color.blueComponent)
            colorData.green = Double(color.greenComponent)
            colorData.alpha = Double(color.alphaComponent)
        }
        
        return colorData
    }

}
