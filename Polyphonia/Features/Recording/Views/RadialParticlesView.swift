//
//  RadialParticlesView.swift
//  Polyphonia
//
//  Created by Gemini.
//

import SwiftUI

struct RadialParticlesView: View {
    /// Normalized amplitude (0.0 - 1.0)
    var amplitude: Float
    
    /// Base configuration
    var color: Color = .accentColor
    var minRadius: CGFloat = 60
    var maxRadius: CGFloat = 140
    var particleCount: Int = 40
    var particleSize: CGFloat = 6
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                // Compute dynamic expansion based on amplitude
                // We square the amplitude to make the response feel more natural (non-linear)
                let expansionFactor = CGFloat(pow(amplitude, 1.5))
                let currentExpansion = (maxRadius - minRadius) * expansionFactor
                
                for i in 0..<particleCount {
                    let angleStep = (2 * .pi) / Double(particleCount)
                    let angle = Double(i) * angleStep
                    
                    // Add some organic movement
                    // Each particle has a unique phase based on its index
                    let indexPhase = Double(i) * 0.5
                    
                    // Idle breathing: slight radial movement when amplitude is 0
                    let breathing = sin(time * 1.5 + indexPhase) * 3.0
                    
                    // Dynamic response: particles push out with amplitude
                    // We add a little randomness or wave offset based on angle
                    let waveOffset = sin(angle * 4 + time * 5) * (currentExpansion * 0.1)
                    
                    let radius = minRadius + currentExpansion + breathing + waveOffset
                    
                    // Position
                    let x = center.x + cos(angle) * radius
                    let y = center.y + sin(angle) * radius
                    
                    // Draw
                    let rect = CGRect(
                        x: x - particleSize / 2,
                        y: y - particleSize / 2,
                        width: particleSize,
                        height: particleSize
                    )
                    
                    // Opacity / Size dynamic adjustments
                    // Particles fade slightly as they go further out
                    let opacity = 1.0 - (Double(currentExpansion) / Double(maxRadius - minRadius)) * 0.6
                    
                    var particleContext = context
                    particleContext.opacity = opacity
                    particleContext.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
    }
}

#Preview("Idle") {
    RadialParticlesView(amplitude: 0.0)
        .frame(width: 300, height: 300)
        .background(Color.black)
}

#Preview("High Energy") {
    RadialParticlesView(amplitude: 0.8)
        .frame(width: 300, height: 300)
        .background(Color.black)
}

#Preview("Animated Mock") {
    MockAnimationContainer()
}

// Helper for preview animation
private struct MockAnimationContainer: View {
    @State private var amplitude: Float = 0.0
    
    var body: some View {
        RadialParticlesView(amplitude: amplitude)
            .frame(width: 300, height: 300)
            .background(Color.black)
            .onAppear {
                withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: true)) {
                    amplitude = 0.8
                }
            }
    }
}
