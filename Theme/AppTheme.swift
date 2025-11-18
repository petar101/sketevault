import SwiftUI

// MARK: - Colors
extension Color {
    static let appBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.secondarySystemGroupedBackground)
    static let primaryAccent = Color.accentColor
    static let subtleAccent = Color.accentColor.opacity(0.1)
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

