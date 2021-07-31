//
//  ColorAppearance.swift
//  SwiftColorTools
//
//  Created by Alexandra Bashkirova on 29.07.2021.
//

import Foundation

struct ColorAppearance: Hashable {
    let appearance: Appearance
    let isHigh: Bool
    
    enum Appearance {
        case any, light, dark
    }
    
    init(appearance: Appearance = .any, isHigh: Bool = false) {
        self.appearance = appearance
        self.isHigh = isHigh
    }
    
    init(data: [AssetColorData.Element.AppearanceData]?) {
        guard let appearanceData = data else {
            appearance = .any
            isHigh = false
            return
        }
        
        isHigh = appearanceData.contains(where: { $0.appearance == .contrast })
        if
            appearanceData.contains(where: { $0.appearance == .luminosity }),
            let luminosity = appearanceData.first(where: { $0.appearance == .luminosity })
        {
            switch luminosity.value {
            case .dark:
                appearance = .dark
            
            case .light:
                appearance = .light
                
            default:
                appearance = .any
            }
        }
        else {
            appearance = .any
        }

    }
    
    var name: String {
        switch appearance {
        case .any:
            return (isHigh ? "High" : "Any")
        case .dark:
            return "Dark" + (isHigh ? " High" : "")
        case .light:
            return "Light" + (isHigh ? " High" : "")
        }
    }
}

extension ColorAppearance {
    static var `default`: ColorAppearance = .init()
    static var light: ColorAppearance = .init(appearance: .light)
    static var dark: ColorAppearance = .init(appearance: .dark)
}
