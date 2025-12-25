//
//  ResultView.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var quizManager: QuizManager
    @ObservedObject var statsManager: StatsManager
    @State private var showConfetti = false
    @State private var trophyScale: CGFloat = 0.5
    @State private var buttonPressed: String? = nil
    @State private var countUpValue: Int = 0
    
    var body: some View {
        // Guard against nil session
        guard let session = quizManager.currentSession else {
            return AnyView(
                ZStack {
                    Theme.Gradients.backgroundTop.ignoresSafeArea()
                    VStack(spacing: Theme.Spacing.lg) {
                        Text("No quiz data available")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        Button("Back to Home") {
                            quizManager.endQuiz()
                        }
                        .primaryButtonStyle()
                        .padding(.horizontal)
                    }
                }
            )
        }
        
        // Check if quiz was quit early
        if session.quitEarly {
            return AnyView(
                ZStack {
                    Theme.Gradients.backgroundTop.ignoresSafeArea()
                    
                    VStack(spacing: Theme.Spacing.xl) {
                        Spacer()
                        
                        Text("😔")
                            .font(.system(size: 100))
                            .scaleEffect(trophyScale)
                            .onAppear {
                                withAnimation(Theme.Animation.bouncy) {
                                    trophyScale = 1.0
                                }
                            }
                        
                        VStack(spacing: Theme.Spacing.md) {
                            Text("Quiz Canceled")
                                .font(Theme.Typography.heroTitle)
                                .foregroundStyle(Theme.Gradients.warning)
                            
                            Text("Your progress was not saved.")
                                .font(Theme.Typography.title3)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            quizManager.endQuiz()
                        } label: {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Return to Home")
                            }
                        }
                        .primaryButtonStyle()
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }
            )
        }
        
        let accuracy = Double(session.correctCount) / Double(session.totalQuestions)
        let duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
        let isPerfect = accuracy == 1.0
        
        return AnyView(
            ZStack {
                // Background gradient
                Theme.Gradients.backgroundTop.ignoresSafeArea()
                
                // Confetti for perfect score
                if showConfetti && isPerfect {
                    ConfettiView()
                        .ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xl) {
                        // Animated Header
                        VStack(spacing: Theme.Spacing.lg) {
                            Text(getEmoji(accuracy: accuracy))
                                .font(.system(size: 120))
                                .scaleEffect(trophyScale)
                                .shadow(
                                    color: Theme.Colors.accentYellow.opacity(0.3),
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )
                                .onAppear {
                                    withAnimation(
                                        .spring(response: 0.6, dampingFraction: 0.5)
                                    ) {
                                        trophyScale = 1.0
                                    }
                                    
                                    if isPerfect {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            showConfetti = true
                                        }
                                    }
                                    
                                    // Animate count up
                                    let totalCount = session.correctCount
                                    for i in 0...totalCount {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.05) {
                                            countUpValue = i
                                        }
                                    }
                                }
                            
                            VStack(spacing: Theme.Spacing.sm) {
                                Text("Quiz Complete!")
                                    .font(Theme.Typography.heroTitle)
                                    .foregroundStyle(Theme.Gradients.celebration)
                                
                                Text(getMessage(accuracy: accuracy))
                                    .font(Theme.Typography.title3)
                                    .foregroundStyle(Theme.Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.top, Theme.Spacing.xxl)
                        
                        // Animated Results Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                            AnimatedResultCard(
                                icon: "checkmark.circle.fill",
                                gradient: Theme.Gradients.success,
                                title: "Score",
                                value: "\(countUpValue) / \(session.totalQuestions)",
                                delay: 0.1
                            )
                            
                            AnimatedResultCard(
                                icon: "target",
                                gradient: Theme.Gradients.primary,
                                title: "Accuracy",
                                value: String(format: "%.1f%%", accuracy * 100),
                                delay: 0.2
                            )
                            
                            AnimatedResultCard(
                                icon: "clock.fill",
                                gradient: Theme.Gradients.warning,
                                title: "Time",
                                value: formatDuration(duration),
                                delay: 0.3
                            )
                            
                            AnimatedResultCard(
                                icon: "flame.fill",
                                gradient: LinearGradient(
                                    colors: [Theme.Colors.errorRed, Theme.Colors.warningOrange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                title: "Streak",
                                value: "\(statsManager.currentStreak)",
                                delay: 0.4
                            )
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: Theme.Spacing.md) {
                            Button {
                                buttonPressed = "again"
                                withAnimation(Theme.Animation.bouncy) {
                                    buttonPressed = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    quizManager.startQuiz(questionCount: session.totalQuestions, continent: session.continent)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("Try Again")
                                }
                                .font(Theme.Typography.title2)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.lg)
                                .background(Theme.Gradients.primary)
                                .cornerRadius(Theme.CornerRadius.md)
                                .shadow(
                                    color: Theme.Colors.primaryBlue.opacity(0.4),
                                    radius: Theme.Shadow.colored.radius,
                                    x: Theme.Shadow.colored.x,
                                    y: Theme.Shadow.colored.y
                                )
                            }
                            .scaleEffect(buttonPressed == "again" ? 0.95 : 1.0)
                            .sensoryFeedback(.impact, trigger: buttonPressed == "again")
                            
                            Button {
                                buttonPressed = "home"
                                withAnimation(Theme.Animation.bouncy) {
                                    buttonPressed = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    quizManager.endQuiz()
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "house.fill")
                                    Text("Back to Home")
                                }
                                .font(Theme.Typography.title3)
                                .foregroundStyle(Theme.Colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.lg)
                            }
                            .cardStyle()
                            .scaleEffect(buttonPressed == "home" ? 0.95 : 1.0)
                            .sensoryFeedback(.impact, trigger: buttonPressed == "home")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }
            }
        )
    }
    
    private func getEmoji(accuracy: Double) -> String {
        if accuracy >= 0.9 {
            return "🏆"
        } else if accuracy >= 0.8 {
            return "🎉"
        } else if accuracy >= 0.6 {
            return "👍"
        } else {
            return "💪"
        }
    }
    
    private func getMessage(accuracy: Double) -> String {
        if accuracy >= 0.9 {
            return "Outstanding! You're a geography master!"
        } else if accuracy >= 0.8 {
            return "Great job! Keep up the excellent work!"
        } else if accuracy >= 0.6 {
            return "Good effort! Practice makes perfect!"
        } else {
            return "Keep trying! You'll improve with practice!"
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct AnimatedResultCard: View {
    let icon: String
    let gradient: LinearGradient
    let title: String
    let value: String
    let delay: Double
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(gradient)
            
            VStack(spacing: Theme.Spacing.xs) {
                Text(value)
                    .font(Theme.Typography.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .gradientCardStyle(gradient: Theme.Gradients.quizCard)
        .scaleEffect(appeared ? 1.0 : 0.5)
        .opacity(appeared ? 1.0 : 0.0)
        .onAppear {
            withAnimation(
                Theme.Animation.bouncy.delay(delay)
            ) {
                appeared = true
            }
        }
    }
}

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var scale: CGFloat
        var color: Color
        var opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                for piece in confettiPieces {
                    let progress = (now - piece.y) * 100
                    let yPos = progress
                    
                    if yPos < size.height + 50 {
                        context.opacity = piece.opacity
                        
                        var transform = CGAffineTransform(translationX: piece.x, y: yPos)
                        transform = transform.rotated(by: piece.rotation + progress * 0.1)
                        transform = transform.scaledBy(x: piece.scale, y: piece.scale)
                        
                        let rect = CGRect(x: -5, y: -5, width: 10, height: 10)
                        context.transform = transform
                        context.fill(Path(ellipseIn: rect), with: .color(piece.color))
                    }
                }
            }
        }
        .onAppear {
            generateConfetti()
        }
    }
    
    private func generateConfetti() {
        let colors = [
            Theme.Colors.accentYellow,
            Theme.Colors.primaryBlue,
            Theme.Colors.primaryPurple,
            Theme.Colors.successGreen,
            Theme.Colors.accentTeal,
            Theme.Colors.warningOrange,
            Theme.Colors.accentPink
        ]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...2),
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.5),
                color: colors.randomElement() ?? .blue,
                opacity: Double.random(in: 0.6...1.0)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ResultCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let statsManager = StatsManager()
    let quizManager = QuizManager(statsManager: statsManager)
    quizManager.startQuiz(questionCount: 5)
    return ResultView(quizManager: quizManager, statsManager: statsManager)
}
