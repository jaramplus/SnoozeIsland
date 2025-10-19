import SwiftUI
import UIKit
import ImageIO

struct GIFView: UIViewRepresentable {
    let gifName: String
    let speed: Double = 3.0

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = loadGIF(named: gifName)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // gifName이 바뀌었는지 확인하고 다시 로드
        if uiView.accessibilityIdentifier != gifName {
            uiView.image = loadGIF(named: gifName)
            uiView.accessibilityIdentifier = gifName // 추적용 식별자 설정
        }
    }

    private func loadGIF(named name: String) -> UIImage? {
        guard let path = Bundle.main.path(forResource: name, ofType: "gif"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        var images: [UIImage] = []
        var totalDuration: Double = 0

        let count = CGImageSourceGetCount(source)
        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }

            // Adjust duration based on speed multiplier
            let frameDuration = 0.1 / speed
            totalDuration += frameDuration

            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }

        return UIImage.animatedImage(with: images, duration: totalDuration)
    }
}
