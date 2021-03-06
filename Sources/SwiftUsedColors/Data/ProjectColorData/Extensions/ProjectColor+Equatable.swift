//
//  ProjectColor+Equatable.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor.Color: Equatable {
    static func == (lhs: ProjectColor.Color, rhs: ProjectColor.Color) -> Bool {
        switch (lhs, rhs) {
        case (.rgb, .rgb):
            return lhs.hex == rhs.hex
       
        case (.grayGamma(let lhsWhite, let lhsAlpha, _), .grayGamma(let rhsWhite, let rhsAlpha, _)):
            return abs(lhsWhite - rhsWhite) < Float.ulpOfOne && abs(lhsAlpha - rhsAlpha) < Float.ulpOfOne
       
        default:
            return false
            
        }
    }
}

extension ProjectColor.AppearanceColor: Equatable {
    static func == (lhs: ProjectColor.AppearanceColor, rhs: ProjectColor.AppearanceColor) -> Bool {
        switch (lhs, rhs) {
        case (.any(let lhsColor), .any(let rhsColor)):
            return lhsColor == rhsColor
        
        case (.anyDark(let lhsLight, let lhsDark), .anyDark(let rhsLight, let rhsDark)):
            return lhsLight == rhsLight && lhsDark == rhsDark
        
        default:
            return false
        }
    }
}

extension ProjectColor.ColorRepresentation: Equatable {
    static func == (lhs: ProjectColor.ColorRepresentation, rhs: ProjectColor.ColorRepresentation) -> Bool {
        switch (lhs, rhs) {
        case (.system(let lhsName, let lhsAlpha), .system(let rhsName, let rhsAlpha)):
            return lhsName == rhsName && lhsAlpha == rhsAlpha
            
        case (.custom(let lhsColor), .custom(let rhsColor)):
            return lhsColor == rhsColor
        
        case (.asset(let lhsColor), .asset(let rhsColor)):
            return lhsColor == rhsColor
        
        case (.custom(let lhsColor), .asset(let rhsColor)):
            if case .any(let rhsColor) = rhsColor {
                return lhsColor == rhsColor
            }
            else {
                return false
            }
            
        case (.asset(let lhsColor), .custom(let rhsColor)):
            if case .any(let lhsColor) = lhsColor {
                return lhsColor == rhsColor
            }
            else {
                return false
            }
            
        default:
            return false
        }
    }
}

