import SwiftUI

extension Color {
    // Primary Brand Colors
    static let bloomOrange = Color(hex: "FF6B35")
    static let bloomYellow = Color(hex: "FFB800")
    static let bloomGreen = Color(hex: "4CAF50")
    static let bloomBlue = Color(hex: "4A90D9")
    static let bloomPurple = Color(hex: "9B59B6")
    
    // UI Colors
    static let bloomBackground = Color(hex: "F8F9FA")
    static let bloomCardBackground = Color.white
    static let bloomTextPrimary = Color(hex: "1A1A2E")
    static let bloomTextSecondary = Color(hex: "6B7280")
    static let bloomTextMuted = Color(hex: "9CA3AF")
    
    // Status Colors
    static let bloomSuccess = Color(hex: "10B981")
    static let bloomWarning = Color(hex: "F59E0B")
    static let bloomError = Color(hex: "EF4444")
    
    // Tab Colors
    static let tabActive = Color(hex: "1A1A2E")
    static let tabInactive = Color(hex: "9CA3AF")
    
    // Course Theme Colors
    static let courseOrange = Color(hex: "FF6B35")
    static let courseYellow = Color(hex: "FFB800")
    static let courseBlue = Color(hex: "4A90D9")
    static let coursePurple = Color(hex: "9B59B6")
    static let courseGreen = Color(hex: "4CAF50")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static func courseColor(from hex: String?) -> Color {
        guard let hex = hex else { return .bloomOrange }
        return Color(hex: hex)
    }
}
