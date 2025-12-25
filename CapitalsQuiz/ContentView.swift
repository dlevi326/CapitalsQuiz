//
//  ContentView.swift
//  CapitalsQuiz
//
//  Created by David Levi on 12/25/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var statsManager = StatsManager()
    @StateObject private var quizManager: QuizManager
    
    init() {
        let stats = StatsManager()
        _statsManager = StateObject(wrappedValue: stats)
        _quizManager = StateObject(wrappedValue: QuizManager(statsManager: stats))
    }
    
    var body: some View {
        Group {
            if let session = quizManager.currentSession, !quizManager.showingResults {
                QuizView(quizManager: quizManager)
            } else if quizManager.showingResults {
                ResultView(quizManager: quizManager, statsManager: statsManager)
            } else {
                HomeView(quizManager: quizManager, statsManager: statsManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
