//
//  DraggableItem.swift
//  SnoozeIsland
//
//  Created by jose Yun on 5/18/25.
//

import SwiftUI

struct DraggableItem: Identifiable, Codable {
    let id: UUID  // = UUID() 제거하고 이렇게 변경
    let names: [String]
    var offset: CGSize = .zero
    var dragOffset: CGSize = .zero
    var currentLineIndex: Int = 0
    var isDragging: Bool = false
    
    // 생성자 추가 (필요시)
    init(names: [String], offset: CGSize = .zero, dragOffset: CGSize = .zero, currentLineIndex: Int = 0, isDragging: Bool = false) {
        self.id = UUID()  // 여기서 UUID 생성
        self.names = names
        self.offset = offset
        self.dragOffset = dragOffset
        self.currentLineIndex = currentLineIndex
        self.isDragging = isDragging
    }
}
