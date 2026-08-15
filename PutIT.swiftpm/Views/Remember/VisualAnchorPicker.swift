import SwiftUI

struct VisualAnchorPicker: View {
    let image: UIImage
    @Binding var anchorX: Double?
    @Binding var anchorY: Double?
    
    @State private var pinScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { containerGeo in
            let containerSize = containerGeo.size
            let imageSize = image.size
            let imageFitRect = aspectFitRect(imageSize: imageSize, containerSize: containerSize)
            
            ZStack {
                Color.black
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: containerSize.width, height: containerSize.height)
                
                // Pin overlay
                if let ax = anchorX, let ay = anchorY, imageFitRect.width > 0 && imageFitRect.height > 0 {
                    let pinX = imageFitRect.origin.x + (CGFloat(ax) * imageFitRect.width)
                    let pinY = imageFitRect.origin.y + (CGFloat(ay) * imageFitRect.height)
                    
                    PulsingPinView(size: 38, color: .red, title: "อยู่ตรงนี้")
                        .scaleEffect(pinScale)
                        .position(x: pinX, y: pinY)
                }
                
                // Instruction Overlay Banner
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: anchorX == nil ? "hand.tap.fill" : "checkmark.circle.fill")
                            .foregroundStyle(anchorX == nil ? .yellow : .green)
                        Text(anchorX == nil ? "แตะบนภาพตรงจุดที่วางของเพื่อปักหมุด" : "ปักหมุดแล้ว! แตะจุดอื่นเพื่อย้ายหมุดได้")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 12)
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                if imageFitRect.contains(location) && imageFitRect.width > 0 && imageFitRect.height > 0 {
                    let normalizedX = Double((location.x - imageFitRect.origin.x) / imageFitRect.width)
                    let normalizedY = Double((location.y - imageFitRect.origin.y) / imageFitRect.height)
                    
                    let clampedX = min(max(normalizedX, 0.0), 1.0)
                    let clampedY = min(max(normalizedY, 0.0), 1.0)
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        self.anchorX = clampedX
                        self.anchorY = clampedY
                        self.pinScale = 1.25
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                            self.pinScale = 1.0
                        }
                    }
                }
            }
        }
    }
    
    private func aspectFitRect(imageSize: CGSize, containerSize: CGSize) -> CGRect {
        guard imageSize.width > 0 && imageSize.height > 0 && containerSize.width > 0 && containerSize.height > 0 else {
            return .zero
        }
        let imageAspect = imageSize.width / imageSize.height
        let containerAspect = containerSize.width / containerSize.height
        
        if containerAspect > imageAspect {
            let height = containerSize.height
            let width = height * imageAspect
            let x = (containerSize.width - width) / 2
            return CGRect(x: x, y: 0, width: width, height: height)
        } else {
            let width = containerSize.width
            let height = width / imageAspect
            let y = (containerSize.height - height) / 2
            return CGRect(x: 0, y: y, width: width, height: height)
        }
    }
}
