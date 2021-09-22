//
//  ProjectColor+sortRelation.swift
//  
//
//  Created by Alexandra Bashkirova on 02.08.2021.
//

import Foundation

extension ProjectColor {
    func sortRelation(color: ProjectColor, countOfColorsCluster: Int = 1) -> Bool {
        guard let lColor = colorRepresentation else {
            return false
        }
        guard let rColor = color.colorRepresentation else {
            return true
        }
        return lColor.sortRelation(color: rColor)
    }
}

extension ProjectColor.ColorRepresentation {
    func sortRelation(color: ProjectColor.ColorRepresentation, countOfColorsCluster: Int = 1) -> Bool {
        switch (self, color) {
        case (.custom(let lColor), .custom(let rColor)):
            return lColor.sortRelation(color: rColor, countOfColorsCluster: countOfColorsCluster)
        
        case (.custom(let lColor), .asset(let rColor)):
            let lAppearanceColor: ProjectColor.AppearanceColor = .any(color: lColor)
            return lAppearanceColor.sortRelation(color: rColor, countOfColorsCluster: countOfColorsCluster)
        
        case (.asset(let lColor), .asset(let rColor)):
            return lColor.sortRelation(color: rColor, countOfColorsCluster: countOfColorsCluster)
        
        case (.asset(let lColor), .custom(let rColor)):
            let rAppearanceColor: ProjectColor.AppearanceColor = .any(color: rColor)
            return lColor.sortRelation(color: rAppearanceColor, countOfColorsCluster: countOfColorsCluster)
            
        case (.system(let lName, _), .system(let rName, _)):
            return rName > lName
            
        case (.asset, .system), (.custom, .system):
            return true
        case (.system, .custom), (.system, .asset):
            return false
        }
    }
}

extension ProjectColor.AppearanceColor {
    func sortRelation(color: ProjectColor.AppearanceColor, countOfColorsCluster: Int = 1) -> Bool {
        switch (self, color) {
        case (.any(let lColor), .any(let rColor)):
            return lColor.sortRelation(color: rColor, countOfColorsCluster: countOfColorsCluster)
        case (.anyDark(let lLightColor, _), .anyDark(let rLightColor, _)):
            return lLightColor.sortRelation(color: rLightColor, countOfColorsCluster: countOfColorsCluster)
        case (.any(let lColor), .anyDark(let rLightColor, _)):
            return lColor.sortRelation(color: rLightColor, countOfColorsCluster: countOfColorsCluster)
        case (.anyDark(let lLightColor, _), .any(let rColor)):
            return lLightColor.sortRelation(color: rColor, countOfColorsCluster: countOfColorsCluster)
        }
    }
}

extension ProjectColor.Color {
    func sortRelation(color: ProjectColor.Color, countOfColorsCluster: Int = 1) -> Bool {
        return ProjectColor.Color.luminosityRelation(lhs: self, rhs: color, countOfColorsCluster: countOfColorsCluster)
    }
    
    static func luminosityRelation(lhs: ProjectColor.Color, rhs: ProjectColor.Color, countOfColorsCluster: Int = 1) -> Bool {
        let sortValues = { (hsv: HSV, luminosity: Float) -> (normHue: Int, normLum: Int, normValue: Int) in
            let normHue = Int(hsv.hue * Float(countOfColorsCluster))
            var normLum = Int(luminosity * Float(countOfColorsCluster))
            var normValue = Int(hsv.value * Float(countOfColorsCluster))
            
            if normHue % 2 == 1 {
                normValue = countOfColorsCluster - normValue
                normLum = countOfColorsCluster - normLum
            }
            return (normHue: normHue, normLum: normLum, normValue: normValue)
        }
        
        let lSortValues = sortValues(lhs.hsv, lhs.luminosity)
        let rSortValues = sortValues(rhs.hsv, rhs.luminosity)
        
        if lSortValues.normHue != rSortValues.normHue {
            return lSortValues.normHue > rSortValues.normHue
        }
        else {
            if lSortValues.normLum != rSortValues.normLum {
                return lSortValues.normLum > rSortValues.normLum
            }
            else {
                return lSortValues.normValue > rSortValues.normValue
            }
        }
    }
    
    private var luminosity: Float {
        return sqrt(0.241 * rgb.r + 0.691 * rgb.g + 0.068 * rgb.b)
    }
}
