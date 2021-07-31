//
//  ColorSet+projectColor.swift
//  
//
//  Created by Alexandra Bashkirova on 31.07.2021.
//

import Foundation

extension ColorSet {
    var projectColor: ProjectColor? {
        if let dark = colors[.dark], let light = colors[.light] {
            return ProjectColor(
                colorRepresentation: .asset(color: .anyDark(light: light.projectColor, dark: dark.projectColor)),
                names: [name],
                usedInFiles: [path]
            )
        }
        else if let dark = colors[.dark], let light = colors[.default] {
            return ProjectColor(
                colorRepresentation: .asset(color: .anyDark(light: light.projectColor, dark: dark.projectColor)),
                names: [name],
                usedInFiles: [path]
            )
        }
        else if let any = colors[.default] {
            return ProjectColor(
                colorRepresentation: .asset(color: .any(color: any.projectColor)),
                names: [name],
                usedInFiles: [path]
            )
        }
        else if let light = colors[.light] {
            return ProjectColor(
                colorRepresentation: .asset(color: .any(color: light.projectColor)),
                names: [name],
                usedInFiles: [path]
            )
        }
        else {
            return nil
        }
    }
}
