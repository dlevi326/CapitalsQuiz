//
//  ContentView.swift
//  CapitalsQuiz
//
//  Created by David Levi on 12/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var statsManager = StatsManager()
    @StateObject private var countryCapitalsQuizManager: QuizManager
    @StateObject private var usStatesQuizManager: QuizManager
    @StateObject private var flagsQuizManager: QuizManager
    
    init() {
        let stats = StatsManager()
        _statsManager = StateObject(wrappedValue: stats)
        _countryCapitalsQuizManager = StateObject(wrappedValue: QuizManager(statsManager: stats, quizType: .countryCapitals))
        _usStatesQuizManager = StateObject(wrappedValue: QuizManager(statsManager: stats, quizType: .usStateCapitals))
        _flagsQuizManager = StateObject(wrappedValue: QuizManager(statsManager: stats, quizType: .countryFlags))
    }
    
    var body: some View {
        TabView {
            // Country Capitals Tab
            QuizTabWrapper(
                quizType: .countryCapitals,
                quizManager: countryCapitalsQuizManager,
                statsManager: statsManager
            )
            .tabItem {
                Label(QuizType.countryCapitals.tabLabel, systemImage: QuizType.countryCapitals.tabIcon)
            }
            .badge(countryCapitalsQuizManager.currentSession != nil ? "●" : nil)
            
            // US States Tab (Coming Soon)
            QuizTabWrapper(
                quizType: .usStateCapitals,
                quizManager: usStatesQuizManager,
                statsManager: statsManager
            )
            .tabItem {
                Label(QuizType.usStateCapitals.tabLabel, systemImage: QuizType.usStateCapitals.tabIcon)
            }
            
            // Flags Tab (Coming Soon)
            QuizTabWrapper(
                quizType: .countryFlags,
                quizManager: flagsQuizManager,
                statsManager: statsManager
            )
            .tabItem {
                Label(QuizType.countryFlags.tabLabel, systemImage: QuizType.countryFlags.tabIcon)
            }
            
            // Stats Tab
            StatsView(statsManager: statsManager)
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
        }
    }
}

// Wrapper to handle quiz session state for each tab
struct QuizTabWrapper: View {
    let quizType: QuizType
    @ObservedObject var quizManager: QuizManager
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        Group {
            if quizType.isImplemented {
                if let session = quizManager.currentSession, !quizManager.showingResults {
                    QuizView(quizManager: quizManager)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .id("quiz")
                } else if quizManager.showingResults {
                    ResultView(quizManager: quizManager, statsManager: statsManager)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .id("results")
                } else {
                    HomeView(quizManager: quizManager, statsManager: statsManager, quizType: quizType)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .id("home")
                }
            } else {
                ComingSoonView(quizType: quizType)
                    .id("comingSoon")
            }
        }
        .animation(.smooth(duration: 0.3), value: quizManager.currentSession != nil)
        .animation(.smooth(duration: 0.3), value: quizManager.showingResults)
    }
}

#Preview {
    ContentView()
}

