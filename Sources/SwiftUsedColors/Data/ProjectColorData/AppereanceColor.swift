//
//  ProjectColorData.AppereanceColor.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum AppereanceColor: Codable {
        case any(color: Color)
        case anyDark(light: Color, dark: Color)
    }
}
