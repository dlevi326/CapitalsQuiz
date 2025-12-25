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
    
    var body: some View {
        // Guard against nil session or question
        guard let session = quizManager.currentSession,
              let currentQuestion = session.currentQuestion else {
            return AnyView(ProgressView())
        }
        
        let progress = Double(session.currentQuestionIndex) / Double(session.totalQuestions)
        
        return AnyView(VStack(spacing: 20) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(session.currentQuestionIndex + 1) of \(session.totalQuestions)")
                        .font(.headline)
                    Spacer()
                    Text("\(session.correctCount) correct")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: progress)
                    .tint(.blue)
            }
            .padding()
            
            Spacer()
            
            // Question
            VStack(spacing: 15) {
                Text("What is the capital of")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                Text(currentQuestion.country.name)
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 30)
            
            Spacer()
            
            // Answer Options
            VStack(spacing: 12) {
                ForEach(currentQuestion.options, id: \.self) { option in
                    AnswerButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: showingFeedback && option == currentQuestion.correctAnswer,
                        isWrong: showingFeedback && selectedAnswer == option && option != currentQuestion.correctAnswer,
                        isDisabled: showingFeedback
                    ) {
                        selectAnswer(option)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Next Button
            if showingFeedback {
                Button {
                    nextQuestion()
                } label: {
                    Text(session.currentQuestionIndex + 1 < session.totalQuestions ? "Next Question" : "Finish Quiz")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(15)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        )
    }
    
    private func selectAnswer(_ answer: String) {
        guard let session = quizManager.currentSession,
              let currentQuestion = session.currentQuestion else { return }
        guard !showingFeedback else { return }
        
        selectedAnswer = answer
        isCorrect = answer == currentQuestion.correctAnswer
        
        withAnimation {
            showingFeedback = true
        }
    }
    
    private func nextQuestion() {
        guard let answer = selectedAnswer,
              let session = quizManager.currentSession else { return }
        
        // Reset state first
        selectedAnswer = nil
        showingFeedback = false
        
        // Then submit answer which advances to next question
        quizManager.submitAnswer(answer)
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if isCorrect {
            return .green
        } else if isWrong {
            return .red
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return Color(uiColor: .systemGray6)
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.title3)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                } else if isWrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundStyle(isCorrect || isWrong ? .white : .primary)
            .cornerRadius(12)
        }
        .disabled(isDisabled)
        .animation(.easeInOut(duration: 0.2), value: isCorrect)
        .animation(.easeInOut(duration: 0.2), value: isWrong)
    }
}

#Preview {
    let statsManager = StatsManager()
    let quizManager = QuizManager(statsManager: statsManager)
    quizManager.startQuiz(questionCount: 5)
    return QuizView(quizManager: quizManager)
}
