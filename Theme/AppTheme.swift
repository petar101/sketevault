import SwiftUI

// MARK: - Colors
extension Color {
    // Dark mode background colors
    static let appBackground = Color(red: 0.05, green: 0.05, blue: 0.08) // Deep dark background
    static let cardBackground = Color(red: 0.12, green: 0.12, blue: 0.16) // Slightly lighter for cards
    static let primaryAccent = Color(red: 0.4, green: 0.6, blue: 1.0) // Clean blue accent
    static let subtleAccent = Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.15) // Subtle accent background
    
    // Additional dark mode colors
    static let darkSurface = Color(red: 0.1, green: 0.1, blue: 0.14) // Surface elements
    static let darkBorder = Color.white.opacity(0.1) // Subtle borders
    static let darkTextSecondary = Color.white.opacity(0.6) // Secondary text
}

// MARK: - Typography
struct AppTypography {
    static let title = Font.system(size: 34, weight: .bold, design: .default)
    static let sectionTitle = Font.system(size: 20, weight: .semibold, design: .default)
    static let yearTitle = Font.system(size: 22, weight: .semibold, design: .default)
    static let folderName = Font.system(size: 15, weight: .medium, design: .default)
    static let folderCount = Font.system(size: 13, weight: .regular, design: .default)
    static let photoCount = Font.system(size: 15, weight: .regular, design: .default)
}

// MARK: - Spacing
struct AppSpacing {
    static let small: CGFloat = 6
    static let medium: CGFloat = 12
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 28
}

// MARK: - Corner Radius
struct AppCornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 20
}

