//
//  PostionTestView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 3/3/25.
//

import SwiftUI

struct DraggableBallView: View {
    @State private var positions: [CGSize] = Array(repeating: .zero, count: 6)
    private let centerNodeY: CGFloat = 300 // 기준 노드의 Y 값
    
    var body: some View {
        ZStack {
            // 기준 노드
            Circle()
                .fill(Color.gray)
                .frame(width: 60, height: 60)
                .position(x: UIScreen.main.bounds.width / 2, y: centerNodeY)
            
            ForEach(0..<6, id: \.self) { index in
                let ballY = centerNodeY + positions[index].height
                Circle()
                    .fill(ballY > centerNodeY ? Color.red : Color.green)
                    .frame(width: 50, height: 50)
                    .position(x: 100 + CGFloat(index) * 60, y: centerNodeY)
                    .offset(positions[index])
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                positions[index] = value.translation
                            }
                            .onEnded { value in
                                positions[index] = value.translation
                            }
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    DraggableBallView()
}
