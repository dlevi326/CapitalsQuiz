//
//  Theme.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct Theme {
    
    // MARK: - Color System
    
    struct Colors {
        // Primary Colors
        static let primaryBlue = Color(red: 0.0, green: 0.48, blue: 1.0) // #007AFF
        static let primaryPurple = Color(red: 0.69, green: 0.32, blue: 0.87) // #AF52DE
        
        // Success Colors
        static let successGreen = Color(red: 0.20, green: 0.78, blue: 0.35) // #34C759
        static let accentTeal = Color(red: 0.19, green: 0.84, blue: 0.78) // #30D5C8
        
        // Warning Colors
        static let warningOrange = Color(red: 1.0, green: 0.58, blue: 0.0) // #FF9500
        static let warningCoral = Color(red: 1.0, green: 0.39, blue: 0.51) // #FF6482
        
        // Error Colors
        static let errorRed = Color(red: 1.0, green: 0.23, blue: 0.19) // #FF3B30
        static let errorPink = Color(red: 1.0, green: 0.18, blue: 0.33) // #FF2D54
        
        // Neutral Colors
        static let cardBackground = Color(uiColor: .systemGray6)
        static let cardBackgroundDark = Color(uiColor: .systemGray5)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        // Accent Colors
        static let accentYellow = Color(red: 1.0, green: 0.8, blue: 0.0) // #FFCC00
        static let accentPink = Color(red: 1.0, green: 0.18, blue: 0.58) // #FF2E93
    }
    
    // MARK: - Gradients
    
    struct Gradients {
        // Primary Gradient (Blue → Purple)
        static let primary = LinearGradient(
            colors: [Colors.primaryBlue, Colors.primaryPurple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Success Gradient (Green → Teal)
        static let success = LinearGradient(
            colors: [Colors.successGreen, Colors.accentTeal],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Warning Gradient (Orange → Coral)
        static let warning = LinearGradient(
            colors: [Colors.warningOrange, Colors.warningCoral],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Error Gradient (Red → Pink)
        static let error = LinearGradient(
            colors: [Colors.errorRed, Colors.errorPink],
            startPoint: .leading,
            endPoint: .trailing
        )
        
        // Background Gradient (Subtle)
        static let backgroundTop = LinearGradient(
            colors: [
                Colors.primaryBlue.opacity(0.1),
                Colors.primaryPurple.opacity(0.05),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Card Gradient
        static let card = LinearGradient(
            colors: [
                Color.white.opacity(0.8),
                Color.white.opacity(0.6)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Quiz Card Gradient
        static let quizCard = LinearGradient(
            colors: [
                Colors.primaryBlue.opacity(0.15),
                Colors.primaryPurple.opacity(0.15)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Celebration Gradient (Multi-color)
        static let celebration = LinearGradient(
            colors: [
                Colors.accentYellow,
                Colors.warningOrange,
                Colors.errorPink,
                Colors.primaryPurple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    
    struct Typography {
        static let heroTitle: Font = .system(size: 48, weight: .heavy, design: .rounded)
        static let largeTitle: Font = .system(size: 34, weight: .bold, design: .rounded)
        static let title: Font = .system(size: 28, weight: .bold, design: .rounded)
        static let title2: Font = .system(size: 22, weight: .semibold, design: .rounded)
        static let title3: Font = .system(size: 20, weight: .semibold, design: .rounded)
        static let headline: Font = .system(size: 17, weight: .semibold, design: .rounded)
        static let body: Font = .system(size: 17, weight: .regular, design: .rounded)
        static let callout: Font = .system(size: 16, weight: .regular, design: .rounded)
        static let subheadline: Font = .system(size: 15, weight: .regular, design: .rounded)
        static let footnote: Font = .system(size: 13, weight: .regular, design: .rounded)
        static let caption: Font = .system(size: 12, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    // MARK: - Shadow
    
    struct Shadow {
        static let sm: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.1), 4, 0, 2
        )
        static let md: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.15), 8, 0, 4
        )
        static let lg: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            Color.black.opacity(0.2), 16, 0, 8
        )
        static let colored: (radius: CGFloat, x: CGFloat, y: CGFloat) = (12, 0, 6)
    }
    
    // MARK: - Animation
    
    struct Animation {
        static let bouncy: SwiftUI.Animation = .spring(response: 0.6, dampingFraction: 0.65)
        static let smooth: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.7)
        static let quick: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.8)
        static let gentle: SwiftUI.Animation = .easeInOut(duration: 0.3)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle() -> some View {
        self
            .background(.ultraThinMaterial)
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Theme.Shadow.md.color,
                radius: Theme.Shadow.md.radius,
                x: Theme.Shadow.md.x,
                y: Theme.Shadow.md.y
            )
    }
    
    func gradientCardStyle(gradient: LinearGradient) -> some View {
        self
            .background(
                ZStack {
                    gradient.opacity(0.3)
                    Color.clear.background(.ultraThinMaterial)
                }
            )
            .cornerRadius(Theme.CornerRadius.lg)
            .shadow(
                color: Theme.Shadow.md.color,
                radius: Theme.Shadow.md.radius,
                x: Theme.Shadow.md.x,
                y: Theme.Shadow.md.y
            )
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Gradients.primary)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Colors.primaryBlue.opacity(0.3),
                radius: Theme.Shadow.colored.radius,
                x: Theme.Shadow.colored.x,
                y: Theme.Shadow.colored.y
            )
    }
    
    func successButtonStyle() -> some View {
        self
            .font(Theme.Typography.headline)
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Gradients.success)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Colors.successGreen.opacity(0.3),
                radius: Theme.Shadow.colored.radius,
                x: Theme.Shadow.colored.x,
                y: Theme.Shadow.colored.y
            )
    }
    
    func bouncyTapAnimation(scale: CGFloat = 0.95) -> some View {
        self
            .scaleEffect(1.0)
            .animation(Theme.Animation.bouncy, value: UUID())
    }
}
