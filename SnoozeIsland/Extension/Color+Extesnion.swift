//
//  Color+Extesnion.swift
//  SnoozeIsland
//
//  Created by jose Yun on 4/12/25.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    
    
    init(hex: UInt, alpha: Double = 1.0) {
            let red = Double((hex >> 16) & 0xff) / 255.0
            let green = Double((hex >> 8) & 0xff) / 255.0
            let blue = Double(hex & 0xff) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    
    static var lightPurple: Self { Self(hex: 0xCDB6FC) }
    static var darkPurple: Self { Self(hex: 0x622BCD) }
    static var clickPurple: Self { Self(hex: 0xD5BFE3) }
    
}
