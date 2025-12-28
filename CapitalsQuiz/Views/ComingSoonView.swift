//
//  ComingSoonView.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct ComingSoonView: View {
    let quizType: QuizType
    
    var body: some View {
        ZStack {
            Theme.Gradients.backgroundTop
                .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // Lock Icon with pulse animation
                ZStack {
                    Circle()
                        .fill(Theme.Colors.primaryBlue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Theme.Gradients.primary)
                }
                
                VStack(spacing: Theme.Spacing.sm) {
                    Text(quizType.emoji)
                        .font(.system(size: 80))
                    
                    Text(quizType.title)
                        .font(Theme.Typography.largeTitle)
                        .foregroundStyle(Theme.Gradients.primary)
                    
                    Text("Coming Soon")
                        .font(Theme.Typography.title2)
                        .foregroundStyle(Theme.Colors.textSecondary)
                    
                    Text("This quiz mode is under development")
                        .font(Theme.Typography.body)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
                
                Spacer()
                
                // Feature Preview
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("What to expect:")
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Gradients.primary)
                    
                    FeatureRow(icon: "brain.head.profile", text: "Adaptive learning algorithm")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Detailed progress tracking")
                    FeatureRow(icon: "star.fill", text: "Achievements and streaks")
                }
                .padding(Theme.Spacing.lg)
                .cardStyle()
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Theme.Gradients.primary)
                .frame(width: 24)
            
            Text(text)
                .font(Theme.Typography.body)
                .foregroundStyle(Theme.Colors.textPrimary)
        }
    }
}

#Preview {
    ComingSoonView(quizType: .usStateCapitals)
}
