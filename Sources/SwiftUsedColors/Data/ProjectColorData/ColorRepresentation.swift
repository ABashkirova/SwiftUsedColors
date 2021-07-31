//
//  ProjectColorData.ColorRepresentation.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum ColorRepresentation: Codable {
        case asset(color: AppereanceColor)
        case custom(color: Color)
        case system(name: String, alpha: Float = 1)
    }
}
