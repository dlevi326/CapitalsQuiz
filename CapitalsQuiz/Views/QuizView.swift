//
//  QuizView.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var quizManager: QuizManager
    @State private var selectedAnswer: String?
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var showingQuitAlert = false
    @State private var questionScale: CGFloat = 1.0
    @State private var questionOpacity: Double = 1.0
    @State private var questionOffset: CGFloat = 0
    
    var body: some View {
        // Guard against nil session or question
        guard let session = quizManager.currentSession,
              let currentQuestion = session.currentQuestion else {
            return AnyView(
                ZStack {
                    Theme.Gradients.backgroundTop.ignoresSafeArea()
                    ProgressView()
                        .tint(Theme.Colors.primaryBlue)
                        .scaleEffect(1.5)
                }
            )
        }
        
        let progress = Double(session.currentQuestionIndex) / Double(session.totalQuestions)
        
        return AnyView(
            ZStack {
                // Background gradient
                Theme.Gradients.backgroundTop
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.lg) {
                    // Animated Progress Bar with gradient
                    VStack(spacing: Theme.Spacing.sm) {
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "brain.head.profile")
                                    .foregroundStyle(Theme.Gradients.primary)
                                Text("Question \(session.currentQuestionIndex + 1)")
                                    .font(Theme.Typography.headline)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.Gradients.success)
                                Text("\(session.correctCount)")
                                    .font(Theme.Typography.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                                .fill(Theme.Gradients.primary)
                                .frame(width: UIScreen.main.bounds.width * 0.9 * progress - 32, height: 8)
                                .animation(Theme.Animation.smooth, value: progress)
                        }
                    }
                    .padding()
                    .cardStyle()
                    .padding(.horizontal)
                    .padding(.top, Theme.Spacing.sm)
                    
                    Spacer()
                    
                    // Question Card with animation
                    VStack(spacing: Theme.Spacing.md) {
                        Text("🌍")
                            .font(.system(size: 50))
                            .scaleEffect(questionScale)
                        
                        Text("What is the capital of")
                            .font(Theme.Typography.title3)
                            .foregroundStyle(Theme.Colors.textSecondary)
                        
                        Text(currentQuestion.country.name)
                            .font(Theme.Typography.heroTitle)
                            .foregroundStyle(Theme.Gradients.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal)
                    }
                    .padding(Theme.Spacing.xl)
                    .frame(maxWidth: .infinity)
                    .gradientCardStyle(gradient: Theme.Gradients.quizCard)
                    .padding(.horizontal)
                    .scaleEffect(questionScale)
                    .opacity(questionOpacity)
                    .offset(x: questionOffset)
                    .id(currentQuestion.country.name)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                    
                    Spacer()
                    
                    // Answer Options with bounce animations
                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(Array(currentQuestion.options.enumerated()), id: \.element) { index, option in
                            AnswerButton(
                                text: option,
                                isSelected: selectedAnswer == option,
                                isCorrect: showingFeedback && option == currentQuestion.correctAnswer,
                                isWrong: showingFeedback && selectedAnswer == option && option != currentQuestion.correctAnswer,
                                isDisabled: showingFeedback
                            ) {
                                selectAnswer(option)
                            }
                            .transition(.scale.combined(with: .opacity))
                            .animation(
                                Theme.Animation.bouncy.delay(Double(index) * 0.05),
                                value: currentQuestion.country.name
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Next Button with gradient
                    if showingFeedback {
                        Button {
                            nextQuestion()
                        } label: {
                            HStack {
                                Text(session.currentQuestionIndex + 1 < session.totalQuestions ? "Next Question" : "Finish Quiz")
                                Image(systemName: session.currentQuestionIndex + 1 < session.totalQuestions ? "arrow.right" : "flag.checkered")
                            }
                            .font(Theme.Typography.title2)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(Theme.Spacing.lg)
                            .background(isCorrect ? Theme.Gradients.success : Theme.Gradients.primary)
                            .cornerRadius(Theme.CornerRadius.md)
                            .shadow(
                                color: (isCorrect ? Theme.Colors.successGreen : Theme.Colors.primaryBlue).opacity(0.4),
                                radius: Theme.Shadow.colored.radius,
                                x: Theme.Shadow.colored.x,
                                y: Theme.Shadow.colored.y
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .sensoryFeedback(.success, trigger: showingFeedback)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingQuitAlert = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill")
                                Text("Quit")
                            }
                            .foregroundStyle(Theme.Gradients.error)
                        }
                    }
                }
                .alert("Quit Quiz?", isPresented: $showingQuitAlert) {
                    Button("Cancel", role: .cancel) {}
                    Button("Quit", role: .destructive) {
                        quizManager.quitQuiz()
                    }
                } message: {
                    Text("Your progress will not be saved.")
                }
            }
            .safeAreaPadding(.bottom)
        )
    }
    
    private func selectAnswer(_ answer: String) {
        guard let session = quizManager.currentSession,
              let currentQuestion = session.currentQuestion else { return }
        guard !showingFeedback else { return }
        
        selectedAnswer = answer
        isCorrect = answer == currentQuestion.correctAnswer
        
        // Bounce animation for question card
        withAnimation(Theme.Animation.bouncy) {
            questionScale = 1.05
        }
        withAnimation(Theme.Animation.bouncy.delay(0.1)) {
            questionScale = 1.0
        }
        
        withAnimation(Theme.Animation.smooth) {
            showingFeedback = true
        }
    }
    
    private func nextQuestion() {
        guard let answer = selectedAnswer,
              let session = quizManager.currentSession else { return }
        
        // Animate question out
        withAnimation(Theme.Animation.quick) {
            questionOffset = -50
            questionOpacity = 0
        }
        
        // Reset state and submit answer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            selectedAnswer = nil
            showingFeedback = false
            questionOffset = 50
            
            quizManager.submitAnswer(answer)
            
            // Animate question in
            withAnimation(Theme.Animation.smooth) {
                questionOffset = 0
                questionOpacity = 1
            }
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var backgroundColor: LinearGradient {
        if isCorrect {
            return Theme.Gradients.success
        } else if isWrong {
            return Theme.Gradients.error
        } else {
            return LinearGradient(
                colors: [Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var body: some View {
        Button(action: {
            isPressed = true
            withAnimation(Theme.Animation.bouncy) {
                isPressed = false
            }
            action()
        }) {
            HStack {
                Text(text)
                    .font(Theme.Typography.title3)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                        .transition(.scale.combined(with: .opacity))
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(Theme.Colors.primaryBlue)
                        .font(.title3)
                }
            }
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isCorrect || isWrong {
                        backgroundColor
                    } else {
                        Color.clear.background(.ultraThinMaterial)
                    }
                }
            )
            .foregroundStyle(isCorrect || isWrong ? .white : Theme.Colors.textPrimary)
            .cornerRadius(Theme.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                    .stroke(
                        isSelected ? Theme.Gradients.primary : LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isCorrect ? Theme.Colors.successGreen.opacity(0.3) :
                       isWrong ? Theme.Colors.errorRed.opacity(0.3) :
                       Theme.Shadow.sm.color,
                radius: isCorrect || isWrong ? Theme.Shadow.md.radius : Theme.Shadow.sm.radius,
                x: 0,
                y: isCorrect || isWrong ? Theme.Shadow.md.y : Theme.Shadow.sm.y
            )
        }
        .disabled(isDisabled)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(Theme.Animation.bouncy, value: isCorrect)
        .animation(Theme.Animation.bouncy, value: isWrong)
        .animation(Theme.Animation.bouncy, value: isPressed)
        .sensoryFeedback(.success, trigger: isCorrect)
        .sensoryFeedback(.error, trigger: isWrong)
        .sensoryFeedback(.impact(weight: .light), trigger: isPressed)
    }
}

#Preview {
    let statsManager = StatsManager()
    let quizManager = QuizManager(statsManager: statsManager)
    quizManager.startQuiz(questionCount: 5)
    return QuizView(quizManager: quizManager)
}

