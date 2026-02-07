//
//  WaveParticlesView.swift
//  Polyphonia
//
//  Created by Michele Coppola on 06/02/26.
//

import SwiftUI

struct WaveParticlesView: View {
    var amplitude: Float
    
    // Configuration
    var color: Color = .accentColor
    var particleCount: Int = 80
    var particleSize: CGFloat = 4
    var waveFrequency: Double = 3.0 // How many "bumps" in the wave
    var waveSpeed: Double = 4.0      // How fast it moves
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let verticalCenter = size.height / 2
                let width = size.width
                
                // Non-linear scaling for a more dramatic "reactive" feel
                let dynamicAmplitude = CGFloat(pow(amplitude, 1.2)) * (size.height * 0.4)
                
                for i in 0..<particleCount {
                    // 1. Calculate horizontal position
                    // We spread particles evenly across the width
                    let progress = CGFloat(i) / CGFloat(particleCount - 1)
                    let x = progress * width
                    
                    // 2. Calculate the wave (y-offset)
                    // We use a sine wave based on the x position and current time
                    let angle = (Double(progress) * .pi * waveFrequency) + (time * waveSpeed)
                    
                    // Base wave height + idle "breathing" so it's never perfectly flat
                    let idleMovement = sin(time * 2 + Double(i) * 0.2) * 2.0
                    let waveHeight = sin(angle) * Double(dynamicAmplitude)
                    
                    let y = verticalCenter + CGFloat(waveHeight) + CGFloat(idleMovement)
                    
                    // 3. Dynamic styling
                    // Particles in the "peaks" or during high amplitude can be brighter
                    let alpha = 0.4 + (Double(amplitude) * 0.6)
                    
                    // Slight vertical scaling of particles based on amplitude
                    let currentSize = particleSize + (CGFloat(amplitude) * 2)
                    
                    let rect = CGRect(
                        x: x - currentSize / 2,
                        y: y - currentSize / 2,
                        width: currentSize,
                        height: currentSize
                    )
                    
                    // 4. Draw
                    var particleContext = context
                    particleContext.opacity = alpha
                    
                    // Glow effect: Draw a slightly larger, blurrier version if amplitude is high
                    if amplitude > 0.6 {
                        particleContext.addFilter(.blur(radius: 2))
                        particleContext.fill(Path(ellipseIn: rect.insetBy(dx: -2, dy: -2)), with: .color(color.opacity(0.3)))
                    }
                    
                    particleContext.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
            
        }
    }
}

// MARK: - Previews

#Preview("Wave Idle") {
    WaveParticlesView(amplitude: 0.0)
        .frame(height: 200)
        .padding()
        .background(Color.black)
}

#Preview("Wave Active") {
    WaveParticlesView(amplitude: 0.7, color: .cyan)
        .frame(height: 200)
        .padding()
        .background(Color.black)
}

#Preview("Animated Wave") {
    WaveMockContainer()
}

private struct WaveMockContainer: View {
    @State private var amp: Float = 0.0
    var body: some View {
        VStack {
            WaveParticlesView(amplitude: amp, color: .purple)
                .frame(height: 300)
                .background(Color.black)
            
            Slider(value: $amp, in: 0...1)
                .padding()
                .tint(.purple)
        }
    }
}
