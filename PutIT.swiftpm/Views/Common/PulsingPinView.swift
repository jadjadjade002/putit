import SwiftUI

struct PulsingPinView: View {
    var size: CGFloat = 36
    var color: Color = .red
    var title: String? = nil
    
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer Pulse Beacon
                if !reduceMotion {
                    Circle()
                        .fill(color.opacity(0.35))
                        .frame(width: size * (isPulsing ? 2.2 : 1.0), height: size * (isPulsing ? 2.2 : 1.0))
                        .opacity(isPulsing ? 0 : 0.8)
                        .animation(
                            Animation.easeOut(duration: 1.6).repeatForever(autoreverses: false),
                            value: isPulsing
                        )
                }
                
                // Outer Glow Ring
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .background(Circle().fill(color))
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                
                // Inner Dot / Target
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.35, height: size * 0.35)
            }
            .onAppear {
                if !reduceMotion {
                    isPulsing = true
                }
            }
            
            if let title = title, !title.isEmpty {
                Text(title)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.75))
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    )
                    .shadow(radius: 2)
            }
        }
    }
}
