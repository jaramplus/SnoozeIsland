//
//  PrimaryButton.swift
//  SnoozeIsland
//
//  Created by jose Yun on 1/31/25.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    var labelColor = Color.black.opacity(0.8)
    var backgroundColor = Color.white.opacity(0.3)
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(labelColor)
      .padding(.horizontal, 20)
      .padding(.vertical, 13)
      .background(Capsule().fill(backgroundColor))
      .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // <-
  }
}
