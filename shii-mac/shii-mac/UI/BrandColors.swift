import SwiftUI

extension Color {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static let brandBg = Color(hex: "#09090b")
    static let brandCard = Color(hex: "#121214")
    static let brandCardBorder = Color(hex: "#27272a")
    static let brandTextMain = Color(hex: "#fafafa")
    static let brandTextMuted = Color(hex: "#a1a1aa")
    static let brandAccent = Color(hex: "#e3e8a6")
    static let brandAccentHover = Color(hex: "#f4f8b9")
    static let brandChipGreen = Color(hex: "#22c55e")
    static let brandChipOrange = Color(hex: "#f97316")
    static let brandChipBlue = Color(hex: "#3b82f6")
}
