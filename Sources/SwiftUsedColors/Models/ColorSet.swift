//
//  ColorSet.swift
//  
//
//  Created by Alexandra Bashkirova on 30.07.2021.
//

import Foundation
import PathKit

struct ColorSet {
    var name: String
    var path: Path
    var colors: [ColorAppearance : ColorData]
    
    init() {
        name = ""
        path = Path()
        colors = [:]
    }
    
    init(name: String, path: Path, colors: [ColorAppearance : ColorData]) {
        self.name = name
        self.path = path
        self.colors = colors
    }
}

