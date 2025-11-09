//
//  IslandGridView.swift
//  SnoozeIsland
//

import SwiftUI
import UIKit

// 섬 이미지의 알파 채널을 체크하는 유틸리티
class IslandMaskChecker {
    private var alphaData: [UInt8]?
    private var width: Int = 0
    private var height: Int = 0
    
    init(imageName: String) {
        guard let image = UIImage(named: imageName),
              let cgImage = image.cgImage else { return }
        
        width = cgImage.width
        height = cgImage.height
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        alphaData = pixelData
    }
    
    // 특정 위치가 섬 내부인지 확인 (알파값이 일정 이상인지)
    func isPointInsideIsland(x: CGFloat, y: CGFloat, imageWidth: CGFloat, imageHeight: CGFloat) -> Bool {
        guard let alphaData = alphaData else { return true }
        
        // 비율로 픽셀 좌표 계산
        let pixelX = Int((x / imageWidth) * CGFloat(width))
        let pixelY = Int((y / imageHeight) * CGFloat(height))
        
        guard pixelX >= 0, pixelX < width, pixelY >= 0, pixelY < height else {
            return false
        }
        
        let pixelIndex = (pixelY * width + pixelX) * 4
        let alpha = alphaData[pixelIndex + 3]
        
        // 알파값이 50 이상이면 섬 내부로 간주
        return alpha > 50
    }
}

struct IslandGridView: View {
    @EnvironmentObject var snoozeViewModel: SnoozeIslandViewModel
    @State private var maskChecker = IslandMaskChecker(imageName: "island")

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            let containerHeight = geo.size.height
            let imageAspectRatio: CGFloat = 1024 / 768
            let imageHeight = containerWidth / imageAspectRatio

            VStack {
                Spacer()
                ZStack {
                    GeometryReader { imageGeo in
                        let islandWidth = imageGeo.size.width
                        let islandHeight = imageGeo.size.height

                        let linePositions: [CGFloat] = [
                            islandHeight * 0.05,
                            islandHeight * 0.2,
                            islandHeight * 0.35,
                            islandHeight * 0.55
                        ]

                        ZStack {
                            Image("island")
                                .resizable()
                                .scaledToFill()
                                .frame(width: containerWidth)
                                .allowsHitTesting(false)

                            ForEach(linePositions, id: \.self) { y in
                                Rectangle()
                                    .fill(.clear)
                                    .frame(width: islandWidth, height: 2)
                                    .position(x: islandWidth / 2, y: y)
                            }

                            ForEach(snoozeViewModel.creatures) { item in
                                DraggableView(
                                    item: binding(for: item),
                                    names: item.names,
                                    linePositions: linePositions,
                                    containerWidth: islandWidth,
                                    containerHeight: islandHeight,
                                    maskChecker: maskChecker
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
    let containerHeight: CGFloat
    let maskChecker: IslandMaskChecker

    let itemSize: CGFloat = 100

    var body: some View {
        ZStack {
            GIFView(gifName: snoozeViewModel.isNight ? names[1] : names[0])
                .scaleEffect(0.2)
                .scaledToFit()
                .frame(width: itemSize, height: itemSize)
        }
        .frame(width: itemSize, height: itemSize)
        .contentShape(Rectangle())
        .position(x: computedX, y: computedY)
        .zIndex(item.isDragging ? 1 : 0)
        .gesture(
            DragGesture()
                .onChanged { value in
                    item.dragOffset = value.translation
                    item.isDragging = true
                }
                .onEnded { value in
                    let potentialX = computedX
                    let potentialY = computedYWithoutDrag + value.translation.height
                    
                    // 해당 위치가 섬 내부인지 확인
                    let isValid = maskChecker.isPointInsideIsland(
                        x: potentialX,
                        y: potentialY,
                        imageWidth: containerWidth,
                        imageHeight: containerHeight
                    )
                    
                    if isValid {
                        // 섬 내부라면 위치 저장
                        let nearestIndex = linePositions.enumerated().min(by: {
                            abs($0.element - potentialY) < abs($1.element - potentialY)
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
                    } else {
                        // 섬 밖이라면 이동 방향에서 가장 가까운 섬의 경계로 이동
                        let edgePosition = findIslandEdge(
                            fromX: containerWidth / 2 + item.offset.width,
                            fromY: computedYWithoutDrag,
                            toX: potentialX,
                            toY: potentialY
                        )
                        
                        let nearestIndex = linePositions.enumerated().min(by: {
                            abs($0.element - edgePosition.y) < abs($1.element - edgePosition.y)
                        })?.offset ?? item.currentLineIndex
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            item.offset.width = edgePosition.x - containerWidth / 2
                            
                            if item.offset.width > 150 {
                                item.offset.width = 150
                            } else if item.offset.width < -150 {
                                item.offset.width = -150
                            }
                            
                            item.currentLineIndex = nearestIndex
                            item.dragOffset = .zero
                        }
                    }
                    
                    item.isDragging = false
                }
        )
    }

    private var computedX: CGFloat {
        let baseX = containerWidth / 2 + item.offset.width + item.dragOffset.width
        let minX: CGFloat = 60
        let maxX: CGFloat = containerWidth - 60
        return min(max(baseX, minX), maxX)
    }

    private var computedY: CGFloat {
        let baseY = linePositions[item.currentLineIndex] + item.dragOffset.height
        if names[0].contains("tree") {
            return baseY - 60
        } else {
            return baseY
        }
    }
    
    private var computedYWithoutDrag: CGFloat {
        let baseY = linePositions[item.currentLineIndex]
        if names[0].contains("tree") {
            return baseY - 60
        } else {
            return baseY
        }
    }
    
    // 섬의 경계 찾기 (시작점에서 목표점으로의 직선상에서)
    private func findIslandEdge(fromX: CGFloat, fromY: CGFloat, toX: CGFloat, toY: CGFloat) -> CGPoint {
        let steps = 50 // 탐색 정밀도
        var lastValidPoint = CGPoint(x: fromX, y: fromY)
        
        for i in 1...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let checkX = fromX + (toX - fromX) * t
            let checkY = fromY + (toY - fromY) * t
            
            if maskChecker.isPointInsideIsland(
                x: checkX,
                y: checkY,
                imageWidth: containerWidth,
                imageHeight: containerHeight
            ) {
                lastValidPoint = CGPoint(x: checkX, y: checkY)
            } else {
                // 섬 밖으로 나간 순간 마지막 유효 지점 반환
                break
            }
        }
        
        return lastValidPoint
    }
}

#Preview {
    @Previewable @StateObject var snoozeViewModel = SnoozeIslandViewModel.snoozeViewModel
    
    HomeView()
        .environmentObject(snoozeViewModel)
}
