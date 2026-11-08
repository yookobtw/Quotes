import SwiftUI
import UIKit

/// colorhunt.co palette f4f4f2 · e8e8e8 · bbbfca · 495464,
/// with a night variant that inverts it into deep slate tones.
enum Palette {
    static let paper = adaptive(light: 0xF4F4F2, dark: 0x1E232A)
    static let mist  = adaptive(light: 0xE8E8E8, dark: 0x2A3039)
    static let fog   = adaptive(light: 0xBBBFCA, dark: 0x3B4552)
    static let ink   = adaptive(light: 0x495464, dark: 0xE8E8E8)

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension QuoteCategory {
    /// Each category gets its own blend of the palette's tones.
    var colors: [Color] {
        switch self {
        case .wisdom:     [Palette.paper, Palette.fog]
        case .motivation: [Palette.mist, Palette.fog]
        case .life:       [Palette.paper, Palette.mist]
        case .happiness:  [Palette.paper, Palette.mist, Palette.fog]
        case .courage:    [Palette.fog, Palette.mist]
        case .love:       [Palette.mist, Palette.paper]
        }
    }

    var tint: Color { Palette.ink }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// App-wide light / dark preference.
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var title: String {
        switch self {
        case .system: "Automatic"
        case .light: "Light"
        case .dark: "Night"
        }
    }
    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
