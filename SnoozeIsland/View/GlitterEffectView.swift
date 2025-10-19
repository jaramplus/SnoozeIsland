//
//  GlitterEffectView.swift
//  SnoozeIsland
//
//  Created by jose Yun on 6/1/25.
//

import SwiftUI

struct GlitterParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var speed: CGFloat
    var angle: CGFloat
}

struct GlitterEffectView: View {
    @State private var particles: [GlitterParticle] = []

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            Image("moon")
                .overlay {
                        ForEach(particles) { particle in
                            Circle()
                                .fill(Color.purple.opacity(particle.opacity))
                                .frame(width: particle.size, height: particle.size)
                                .position(x: particle.x, y: particle.y)
                                .blur(radius: 0.5)
                                .shadow(color:.cyan, radius: 12)
                        }
                    }
                    .onReceive(timer) { _ in
                        updateParticles()
                    }
                    .onAppear {
                        generateParticles()
                }
        }
    }

    func generateParticles() {
        for _ in 0..<60 {
            let new = GlitterParticle(
                x: CGFloat.random(in: 0...90),
                y: CGFloat.random(in: 0...100),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.2...1),
                speed: CGFloat.random(in: 0.1...0.2),
                angle: CGFloat.random(in: 0...360)
            )
            particles.append(new)
        }
    }

    func updateParticles() {
        particles = particles.map { particle in
            var p = particle
            let dx = cos(p.angle) * p.speed
            let dy = sin(p.angle) * p.speed
            p.x += dx
            p.y += dy
            p.opacity -= 0.02
            if p.opacity <= 0 {
                // Reset sparkle
                p.x = CGFloat.random(in: 0...90)
                p.y = CGFloat.random(in: 0...100)
                p.opacity = Double.random(in: 0.5...1)
                p.size = CGFloat.random(in: 1...4)
                p.angle = CGFloat.random(in: 0...360)
            }
            return p
        }
    }
}

struct GlitterEffectView_Previews: PreviewProvider {
    static var previews: some View {
        GlitterEffectView()
    }
}

