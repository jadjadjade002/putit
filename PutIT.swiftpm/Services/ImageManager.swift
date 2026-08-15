import UIKit

struct ImageManager {
    /// Resizes UIImage to a maximum dimension and compresses to JPEG Data
    static func prepareImageForStorage(_ image: UIImage, maxDimension: CGFloat = 1600, quality: CGFloat = 0.75) -> Data? {
        let size = image.size
        var targetSize = size
        
        let largestDim = max(size.width, size.height)
        if largestDim > maxDimension {
            let scale = maxDimension / largestDim
            targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        }
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage.jpegData(compressionQuality: quality)
    }
    
    // MARK: - Realistic Scene Generators for Sample Demo Items
    
    /// Generates a realistic TV Stand Drawer with a wooden organizer tray for "Spare House Key"
    static func createTVStandKeyScene() -> Data? {
        let size = CGSize(width: 1200, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            
            // 1. Living Room Wall & Floor
            let wallRect = CGRect(x: 0, y: 0, width: size.width, height: 400)
            cg.setFillColor(UIColor(red: 0.18, green: 0.20, blue: 0.24, alpha: 1.0).cgColor)
            cg.fill(wallRect)
            
            let floorRect = CGRect(x: 0, y: 400, width: size.width, height: 500)
            cg.setFillColor(UIColor(red: 0.12, green: 0.14, blue: 0.17, alpha: 1.0).cgColor)
            cg.fill(floorRect)
            
            // 2. TV Console Cabinet Structure (Modern Walnut Wood)
            let tvStandRect = CGRect(x: 100, y: 220, width: 1000, height: 600)
            let tvStandPath = UIBezierPath(roundedRect: tvStandRect, cornerRadius: 20)
            cg.setFillColor(UIColor(red: 0.28, green: 0.18, blue: 0.12, alpha: 1.0).cgColor)
            tvStandPath.fill()
            
            // 3. Open Drawer (Pulled out towards user)
            let openDrawerRect = CGRect(x: 200, y: 340, width: 800, height: 440)
            let drawerPath = UIBezierPath(roundedRect: openDrawerRect, cornerRadius: 16)
            cg.setFillColor(UIColor(red: 0.40, green: 0.28, blue: 0.20, alpha: 1.0).cgColor)
            drawerPath.fill()
            
            // Drawer Interior (Top-down angle)
            let drawerInsideRect = CGRect(x: 230, y: 370, width: 740, height: 380)
            let insidePath = UIBezierPath(roundedRect: drawerInsideRect, cornerRadius: 12)
            cg.setFillColor(UIColor(red: 0.22, green: 0.16, blue: 0.12, alpha: 1.0).cgColor)
            insidePath.fill()
            
            // 4. Wooden Accessory Tray (Left compartment where key is kept)
            let trayRect = CGRect(x: 270, y: 410, width: 320, height: 300)
            let trayPath = UIBezierPath(roundedRect: trayRect, cornerRadius: 14)
            cg.setFillColor(UIColor(red: 0.55, green: 0.38, blue: 0.24, alpha: 1.0).cgColor)
            trayPath.fill()
            
            let trayInside = CGRect(x: 285, y: 425, width: 290, height: 270)
            cg.setFillColor(UIColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: trayInside, cornerRadius: 10).fill()
            
            // Other items in drawer (Remote control, notebook)
            let remoteRect = CGRect(x: 640, y: 420, width: 140, height: 280)
            cg.setFillColor(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: remoteRect, cornerRadius: 12).fill()
            
            let bookRect = CGRect(x: 810, y: 440, width: 130, height: 240)
            cg.setFillColor(UIColor(red: 0.20, green: 0.35, blue: 0.50, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: bookRect, cornerRadius: 8).fill()
            
            // 5. Silver House Key on the wooden tray
            drawSymbol(name: "key.fill", point: CGPoint(x: 430, y: 560), size: 90, color: .white, in: ctx)
            
            // 6. Realistic Room Context Banner
            drawSceneBadge(room: "🛋️ Living Room", spot: "TV Stand (Drawer #2) › Wooden Tray", rect: CGRect(x: 40, y: 40, width: 560, height: 80), in: ctx)
        }
        
        return image.jpegData(compressionQuality: 0.82)
    }
    
    /// Generates a realistic Closet Safe Box scene for "Passport"
    static func createSafeBoxPassportScene() -> Data? {
        let size = CGSize(width: 1200, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            
            // 1. Closet Interior Wood Background
            let bgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            cg.setFillColor(UIColor(red: 0.20, green: 0.14, blue: 0.10, alpha: 1.0).cgColor)
            cg.fill(bgRect)
            
            // 2. Heavy Steel Safe Box (Open Door)
            let safeBody = CGRect(x: 180, y: 180, width: 840, height: 620)
            cg.setFillColor(UIColor(red: 0.12, green: 0.14, blue: 0.16, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: safeBody, cornerRadius: 20).fill()
            
            // Safe Interior Cavity
            let safeInterior = CGRect(x: 230, y: 220, width: 740, height: 540)
            cg.setFillColor(UIColor(red: 0.08, green: 0.09, blue: 0.10, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: safeInterior, cornerRadius: 14).fill()
            
            // Shelf divider inside safe
            let shelfDivider = CGRect(x: 230, y: 460, width: 740, height: 18)
            cg.setFillColor(UIColor(red: 0.25, green: 0.28, blue: 0.32, alpha: 1.0).cgColor)
            cg.fill(shelfDivider)
            
            // Top Shelf Velvet Document Case (Where Passport is)
            let pouchRect = CGRect(x: 380, y: 280, width: 440, height: 150)
            let pouchPath = UIBezierPath(roundedRect: pouchRect, cornerRadius: 14)
            cg.setFillColor(UIColor(red: 0.12, green: 0.22, blue: 0.38, alpha: 1.0).cgColor)
            pouchPath.fill()
            
            // Passport Symbol inside pouch
            drawSymbol(name: "person.text.rectangle.fill", point: CGPoint(x: 600, y: 355), size: 75, color: .white, in: ctx)
            
            // Emergency cash stack & jewelry box on bottom shelf
            let cashRect = CGRect(x: 300, y: 530, width: 220, height: 140)
            cg.setFillColor(UIColor(red: 0.18, green: 0.35, blue: 0.22, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: cashRect, cornerRadius: 8).fill()
            
            let boxRect = CGRect(x: 620, y: 510, width: 260, height: 180)
            cg.setFillColor(UIColor(red: 0.32, green: 0.12, blue: 0.14, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: boxRect, cornerRadius: 12).fill()
            
            // Context Banner
            drawSceneBadge(room: "🛏️ Master Bedroom", spot: "Wardrobe Safe Box › Top Shelf", rect: CGRect(x: 40, y: 40, width: 560, height: 80), in: ctx)
        }
        
        return image.jpegData(compressionQuality: 0.82)
    }
    
    /// Generates a realistic TV Console Shelf scene for "Nintendo Switch"
    static func createGamingShelfScene() -> Data? {
        let size = CGSize(width: 1200, height: 900)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            
            // 1. Entertainment Room Background
            let bgRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            cg.setFillColor(UIColor(red: 0.14, green: 0.16, blue: 0.20, alpha: 1.0).cgColor)
            cg.fill(bgRect)
            
            // 2. TV Screen Base & Soundbar at top
            let tvBase = CGRect(x: 450, y: 160, width: 300, height: 24)
            cg.setFillColor(UIColor.darkGray.cgColor)
            UIBezierPath(roundedRect: tvBase, cornerRadius: 6).fill()
            
            // 3. Audio/Game Console Shelf (Oak Wood)
            let shelfRect = CGRect(x: 140, y: 260, width: 920, height: 480)
            cg.setFillColor(UIColor(red: 0.32, green: 0.24, blue: 0.18, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: shelfRect, cornerRadius: 16).fill()
            
            // Shelf Compartments
            let comp1 = CGRect(x: 180, y: 300, width: 400, height: 390)
            cg.setFillColor(UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: comp1, cornerRadius: 12).fill()
            
            let comp2 = CGRect(x: 620, y: 300, width: 400, height: 390)
            cg.setFillColor(UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: comp2, cornerRadius: 12).fill()
            
            // Left compartment: Game cases
            for i in 0..<5 {
                let caseRect = CGRect(x: 210 + (i * 36), y: 440, width: 28, height: 210)
                let caseColor = [UIColor.systemRed, UIColor.systemGreen, UIColor.systemBlue, UIColor.systemOrange, UIColor.systemPurple][i]
                cg.setFillColor(caseColor.cgColor)
                UIBezierPath(roundedRect: caseRect, cornerRadius: 4).fill()
            }
            
            // Right compartment: Nintendo Switch Console & Dock
            let dockRect = CGRect(x: 660, y: 450, width: 320, height: 200)
            cg.setFillColor(UIColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1.0).cgColor)
            UIBezierPath(roundedRect: dockRect, cornerRadius: 14).fill()
            
            // Draw Game Controller Symbol
            drawSymbol(name: "gamecontroller.fill", point: CGPoint(x: 820, y: 550), size: 90, color: UIColor.systemRed, in: ctx)
            
            // Context Banner
            drawSceneBadge(room: "🛋️ Living Room", spot: "TV Console Shelf › Right Gaming Bay", rect: CGRect(x: 40, y: 40, width: 580, height: 80), in: ctx)
        }
        
        return image.jpegData(compressionQuality: 0.82)
    }
    
    // MARK: - Helpers
    
    private static func drawSymbol(name: String, point: CGPoint, size: CGFloat, color: UIColor, in ctx: UIGraphicsImageRendererContext) {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .bold)
        if let sfImage = UIImage(systemName: name, withConfiguration: config)?.withTintColor(color, renderingMode: .alwaysOriginal) {
            let origin = CGPoint(x: point.x - sfImage.size.width / 2, y: point.y - sfImage.size.height / 2)
            sfImage.draw(at: origin)
        }
    }
    
    private static func drawSceneBadge(room: String, spot: String, rect: CGRect, in ctx: UIGraphicsImageRendererContext) {
        let cg = ctx.cgContext
        let bgPath = UIBezierPath(roundedRect: rect, cornerRadius: 16)
        cg.setFillColor(UIColor.black.withAlphaComponent(0.65).cgColor)
        bgPath.fill()
        
        cg.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        bgPath.lineWidth = 1.5
        bgPath.stroke()
        
        let roomAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        NSAttributedString(string: room, attributes: roomAttr).draw(at: CGPoint(x: rect.minX + 20, y: rect.minY + 12))
        
        let spotAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.85)
        ]
        NSAttributedString(string: spot, attributes: spotAttr).draw(at: CGPoint(x: rect.minX + 20, y: rect.minY + 44))
    }
}
