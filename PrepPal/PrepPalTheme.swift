import SwiftUI

struct PrepPalTheme {
    // MARK: - Colors
    struct Colors {
            // Primary Colors
            static let primary = Color(hex: "0B9444")  // Spinach Green
            static let secondary = Color(hex: "F7951E")  // Citrus Orange
            static let background = Color(hex: "FAF9F6")  // Alabaster White

            // Accent Colors
            static let accentNavy = Color(hex: "1C2A39")  // Deep Navy
            static let accentRed = Color(hex: "C84E4E")  // Berry Red

            // Functional Colors
            static let success = Color(hex: "5ABF4B")  // Fresh Green
            static let warning = Color(hex: "FFBA08")  // Amber Yellow
            static let info = Color(hex: "58C4DD")  // Sky Blue

            // UI Element Colors
            static let gray100 = Color(hex: "F0F0F0")
            static let gray400 = Color(hex: "9CA3AF")
            static let gray600 = Color(hex: "4B5563")
            
            // Message Bubble Colors
            static let userMessage = accentRed.opacity(0.1)
            static let assistantMessage = background
            
            // Border and Shadows
            static let border = accentNavy.opacity(0.1)
            static let shadow = Color.black.opacity(0.05)
        
        // Add cardBackground
        static let cardBackground = Color(hex: "FFFFFF")  // White for cards
    }


    
    // MARK: - Typography
    struct Typography {
        // Using Lora fonts
        static let headerLarge = Font.loraSemiBold(ofSize: 24)
        static let headerMedium = Font.loraMedium(ofSize: 16)
        static let bodyRegular = Font.loraRegular(ofSize: 14)
        static let caption = Font.loraMedium(ofSize: 12)
        static let pill = Font.loraMedium(ofSize: 12)
        
        static let messageLineSpacing: CGFloat = 1.4
        
        // Add buttonSmall
        static let buttonSmall = Font.loraMedium(ofSize: 12)
    }
    
    // MARK: - Layout
    struct Layout {
        static let basePadding: CGFloat = 16
        static let elementSpacing: CGFloat = 16
        static let cardPadding: CGFloat = 20
        static let pillPadding: CGFloat = 12
        
        // Enhanced shadow properties for depth
        static let shadowRadius: CGFloat = 4
        static let shadowY: CGFloat = 2
        static let shadowOpacity: CGFloat = 0.05
        
        // Refined corner radius
        static let cornerRadius: CGFloat = 12
        static let pillCornerRadius: CGFloat = 16
        static let progressBarHeight: CGFloat = 8
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Font {
    static func loraRegular(ofSize size: CGFloat) -> Font {
        return .custom("Lora-Regular", size: size)
    }
    
    static func loraMedium(ofSize size: CGFloat) -> Font {
        return .custom("Lora-Medium", size: size)
    }
    
    static func loraBold(ofSize size: CGFloat) -> Font {
        return .custom("Lora-Bold", size: size)
    }
    
    static func loraSemiBold(ofSize size: CGFloat) -> Font {
        return .custom("Lora-SemiBold", size: size)
    }
}
