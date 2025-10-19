//
//  IslandGridView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 5/11/25.
//

import SwiftUI

struct IslandGridView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            let containerHeight = geo.size.height
            let imageAspectRatio: CGFloat = 1024 / 768
            let imageHeight = containerWidth / imageAspectRatio

            VStack {
                Spacer()
                ZStack {
                    // 이미지의 실제 렌더링 영역을 감지하기 위한 GeometryReader
                    GeometryReader { imageGeo in
                        let islandWidth = imageGeo.size.width
                        let islandHeight = imageGeo.size.height

                        // 섬 이미지 상에서의 선 위치 (Y 값)
                        let linePositions: [CGFloat] = [
                            islandHeight * 0.05,
                            islandHeight * 0.2,
                            islandHeight * 0.4,
                            islandHeight * 0.6
                        ]
                        
                        

                        ZStack {
                            // 실제 섬 이미지
                            Image("island")
                                .resizable()
                                .scaledToFill()
                                .frame(width: containerWidth)
                                .allowsHitTesting(false)

                            // 섬 이미지 기준 선 (섬 너비만큼)
                            ForEach(linePositions, id: \.self) { y in
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: islandWidth, height: 2)
                                    .position(x: islandWidth / 2, y: y)
                            }

                            // 캐릭터 배치
                            ForEach(snoozeViewModel.creatures) { item in
                                DraggableView(
                                    item: binding(for: item),
                                    names: item.names,
                                    linePositions: linePositions,
                                    containerWidth: islandWidth // 섬 이미지 너비 기준으로 이동
                                )
                            }
                        }
                    }
                    .frame(width: containerWidth, height: imageHeight)
                }
                Spacer()
            }
            .frame(width: containerWidth, height: containerHeight)
        }
    }

    private func binding(for item: DraggableItem) -> Binding<DraggableItem> {
        guard let index = snoozeViewModel.creatures.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Item not found")
        }
        return $snoozeViewModel.creatures[index]
    }
}

struct DraggableView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @Binding var item: DraggableItem
    let names: [String]
    let linePositions: [CGFloat]
    let containerWidth: CGFloat

    let itemSize: CGFloat = 100

    var body: some View {
        ZStack {
            GIFView(gifName: snoozeViewModel.isNight ? names[1] : names[0])
                .scaleEffect(0.2)
                .scaledToFit()
                .frame(width: itemSize, height: itemSize)
        }
        .frame(width: itemSize, height: itemSize)
        .contentShape(Rectangle()) // 전체 프레임 영역을 터치 가능하게 만듦
        .position(x: computedX, y: computedY)
        .zIndex(item.isDragging ? 1 : 0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    item.dragOffset = value.translation
                    item.isDragging = true
                }
                .onEnded { value in
                    let finalY = computedY
                    let nearestIndex = linePositions.enumerated().min(by: {
                        abs($0.element - finalY) < abs($1.element - finalY)
                    })?.offset ?? item.currentLineIndex
                    
                    withAnimation(.spring()) {
                        item.offset.width += value.translation.width
                        
                        if item.offset.width > 150 {
                            item.offset.width = 150
                        } else if item.offset.width < -150 {
                            item.offset.width = -150
                        }
                        
                        item.currentLineIndex = nearestIndex
                        item.dragOffset = .zero
                    }
                    
                    item.isDragging = false
                }
        )
    }

    private var computedX: CGFloat {
        let baseX = containerWidth / 2 + item.offset.width + item.dragOffset.width
        
        // min, max 값으로 제한
        let minX: CGFloat = 50  // 원하는 최소값
        let maxX: CGFloat = containerWidth - 50  // 원하는 최대값
        
        return min(max(baseX, minX), maxX)
    }

    private var computedY: CGFloat {
        if names[0].contains("tree") {
            linePositions[item.currentLineIndex] + item.dragOffset.height - 60
        } else {
            linePositions[item.currentLineIndex] + item.dragOffset.height
        }
    }
}



#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
//    IslandGridView()
    HomeView()
        .environmentObject(snoozeViewModel)
}
