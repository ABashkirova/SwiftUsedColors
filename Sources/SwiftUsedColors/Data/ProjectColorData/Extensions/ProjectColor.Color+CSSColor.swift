//
//  ProjectColor.Color+CSSColor.swift
//  
//
//  Created by Alexandra Bashkirova on 05.08.2021.
//

import Foundation
import HyperSwift

extension ProjectColor.Color {
    var cssColor: CSSColor {
        return CSSColor(r: rgb.r, g: rgb.g, b: rgb.b, a: alpha)
    }
}
