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
    
    func startQuiz(questionCount: Int = 10, continent: Continent? = nil) {
        // Filter countries by continent if specified
        let availableCountries = if let continent = continent {
            CountriesData.allCountries.filter { $0.continent == continent }
        } else {
            CountriesData.allCountries
        }
        
        // Adjust question count based on available countries
        let adjustedCount = min(questionCount, max(5, availableCountries.count))
        
        let selectedCountries = selectCountries(count: adjustedCount, from: availableCountries)
        let questions = selectedCountries.map { country in
            createQuestion(for: country, from: availableCountries)
        }
        currentSession = QuizSession(questions: questions, continent: continent)
        showingResults = false
    }
    
    func submitAnswer(_ answer: String) {
        guard var session = currentSession else { return }
        guard let question = session.currentQuestion else { return }
        
        let isCorrect = session.submitAnswer(answer)
        
        currentSession = session
        
        if session.isComplete && !session.quitEarly {
            // Only commit stats when quiz completes naturally (not quit)
            commitStatsForSession(session)
            statsManager.recordQuizSession(session)
            showingResults = true
        }
    }
    
    func quitQuiz() {
        guard var session = currentSession else { return }
        
        session.quitEarly = true
        session.endTime = Date()
        currentSession = session
        showingResults = true
        // Stats are NOT committed when quitting
    }
    
    private func commitStatsForSession(_ session: QuizSession) {
        // Commit all answers to stats
        for question in session.questions {
            if let isCorrect = session.answers[question.country.name] {
                statsManager.recordAnswer(for: question.country, isCorrect: isCorrect)
            }
        }
    }
    
    func endQuiz() {
        currentSession = nil
        showingResults = false
    }
    
    // Adaptive country selection algorithm
    private func selectCountries(count: Int, from availableCountries: [Country]) -> [Country] {
        var selectedCountries: [Country] = []
        
        // Get never-asked countries from available pool
        let neverAsked = statsManager.getNeverAskedCountries().filter { country in
            availableCountries.contains { $0.id == country.id }
        }
        
        // Get weakest countries from available pool
        let weakest = statsManager.getWeakestCountries(limit: count).filter { country in
            availableCountries.contains { $0.id == country.id }
        }
        
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
        
        // Fill remaining with random countries from available pool
        let remaining = availableCountries.filter { country in
            !selectedCountries.contains { $0.id == country.id }
        }
        selectedCountries.append(contentsOf: remaining.shuffled().prefix(randomCount))
        
        return selectedCountries.shuffled()
    }
    
    private func createQuestion(for country: Country, from availableCountries: [Country]) -> QuizQuestion {
        // Get 3 random wrong answers from the available country pool
        var wrongCapitals = availableCountries
            .filter { $0.capital != country.capital }
            .map { $0.capital }
            .shuffled()
            .prefix(3)
        
        return QuizQuestion(country: country, wrongAnswers: Array(wrongCapitals))
    }
}
