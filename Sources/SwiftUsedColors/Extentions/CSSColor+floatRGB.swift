//
//  CSSColor+floatRGB.swift
//  
//
//  Created by Alexandra Bashkirova on 05.08.2021.
//

import Foundation
import HyperSwift

extension CSSColor {
    init(r: Float, g: Float, b: Float, a: Double) {
        self.init(r: Int(r * 255), g: Int(g * 255), b: Int(b * 255), a: a)
    }
}
