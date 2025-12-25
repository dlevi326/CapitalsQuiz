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
    
    var body: some View {
        // Guard against nil session
        guard let session = quizManager.currentSession else {
            return AnyView(
                VStack {
                    Text("No quiz data available")
                        .foregroundStyle(.secondary)
                    Button("Back to Home") {
                        quizManager.endQuiz()
                    }
                }
            )
        }
        
        // Check if quiz was quit early
        if session.quitEarly {
            return AnyView(
                VStack(spacing: 30) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.orange)
                    
                    Text("Quiz Canceled")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your progress was not saved.")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        quizManager.endQuiz()
                    } label: {
                        Text("Return to Home")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                }
                .padding(.top, 100)
            )
        }
        
        let accuracy = Double(session.correctCount) / Double(session.totalQuestions)
        let duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
        
        return AnyView(
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 15) {
                Image(systemName: accuracy >= 0.8 ? "star.fill" : accuracy >= 0.6 ? "hand.thumbsup.fill" : "flag.checkered")
                    .font(.system(size: 80))
                    .foregroundStyle(accuracy >= 0.8 ? .yellow : accuracy >= 0.6 ? .blue : .orange)
                
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(getMessage(accuracy: accuracy))
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 50)
            
            // Results
            VStack(spacing: 20) {
                ResultCard(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Score",
                    value: "\(session.correctCount) / \(session.totalQuestions)"
                )
                
                ResultCard(
                    icon: "percent",
                    color: .blue,
                    title: "Accuracy",
                    value: String(format: "%.1f%%", accuracy * 100)
                )
                
                ResultCard(
                    icon: "clock.fill",
                    color: .orange,
                    title: "Time",
                    value: formatDuration(duration)
                )
                
                ResultCard(
                    icon: "flame.fill",
                    color: .red,
                    title: "Current Streak",
                    value: "\(statsManager.currentStreak)"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 15) {
                Button {
                    quizManager.startQuiz(questionCount: session.totalQuestions, continent: session.continent)
                } label: {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(15)
                }
                
                Button {
                    quizManager.endQuiz()
                } label: {
                    Text("Back to Home")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(uiColor: .systemGray5))
                        .foregroundStyle(.primary)
                        .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
        }
        )
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
