//
//  ProjectColorData.Color.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation

extension ProjectColor {
    enum Color: Codable {
        case rgb(red: Float, green: Float, blue: Float, alpha: Float)
        case grayGamma(white: Float, alpha: Float)
    }
}
