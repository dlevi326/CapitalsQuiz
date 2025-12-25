//
//  QuizManager.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

@MainActor
class QuizManager: ObservableObject {
    @Published var currentSession: QuizSession?
    @Published var showingResults = false
    
    let statsManager: StatsManager
    
    init(statsManager: StatsManager) {
        self.statsManager = statsManager
    }
    
    func startQuiz(questionCount: Int = 10) {
        let selectedCountries = selectCountries(count: questionCount)
        let questions = selectedCountries.map { country in
            createQuestion(for: country)
        }
        currentSession = QuizSession(questions: questions)
        showingResults = false
    }
    
    func submitAnswer(_ answer: String) {
        guard var session = currentSession else { return }
        guard let question = session.currentQuestion else { return }
        
        let isCorrect = session.submitAnswer(answer)
        statsManager.recordAnswer(for: question.country, isCorrect: isCorrect)
        
        currentSession = session
        
        if session.isComplete {
            statsManager.recordQuizSession(session)
            showingResults = true
        }
    }
    
    func endQuiz() {
        currentSession = nil
        showingResults = false
    }
    
    // Adaptive country selection algorithm
    private func selectCountries(count: Int) -> [Country] {
        var selectedCountries: [Country] = []
        
        // Get never-asked countries
        let neverAsked = statsManager.getNeverAskedCountries()
        
        // Get weakest countries (low accuracy)
        let weakest = statsManager.getWeakestCountries(limit: count)
        
        // Strategy: 
        // - 50% from weakest countries (if available)
        // - 30% from never asked (if available)
        // - 20% random from all countries
        
        let weakCount = min(count / 2, weakest.count)
        let neverAskedCount = min(count * 3 / 10, neverAsked.count)
        let randomCount = count - weakCount - neverAskedCount
        
        // Add weakest countries
        selectedCountries.append(contentsOf: weakest.prefix(weakCount))
        
        // Add never asked countries
        selectedCountries.append(contentsOf: neverAsked.shuffled().prefix(neverAskedCount))
        
        // Fill remaining with random countries
        let remaining = CountriesData.allCountries.filter { country in
            !selectedCountries.contains { $0.id == country.id }
        }
        selectedCountries.append(contentsOf: remaining.shuffled().prefix(randomCount))
        
        return selectedCountries.shuffled()
    }
    
    private func createQuestion(for country: Country) -> QuizQuestion {
        // Get 3 random wrong answers
        var wrongCapitals = CountriesData.allCountries
            .filter { $0.capital != country.capital }
            .map { $0.capital }
            .shuffled()
            .prefix(3)
        
        return QuizQuestion(country: country, wrongAnswers: Array(wrongCapitals))
    }
}
