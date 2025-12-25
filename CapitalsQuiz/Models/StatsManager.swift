//
//  StatsManager.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

@MainActor
class StatsManager: ObservableObject {
    @Published private(set) var countryStats: [String: CountryStats] = [:]
    @Published private(set) var totalQuestionsAnswered: Int = 0
    @Published private(set) var totalCorrectAnswers: Int = 0
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var longestStreak: Int = 0
    @Published private(set) var quizHistory: [QuizHistoryEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let statsKey = "countryStats"
    private let totalQuestionsKey = "totalQuestions"
    private let totalCorrectKey = "totalCorrect"
    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let quizHistoryKey = "quizHistory"
    
    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }
    
    init() {
        loadStats()
    }
    
    func recordAnswer(for country: Country, isCorrect: Bool) {
        // Update or create country stats
        var stats = countryStats[country.name] ?? CountryStats(countryName: country.name)
        stats.timesAsked += 1
        if isCorrect {
            stats.timesCorrect += 1
        }
        stats.lastAsked = Date()
        countryStats[country.name] = stats
        
        // Update overall stats
        totalQuestionsAnswered += 1
        if isCorrect {
            totalCorrectAnswers += 1
            currentStreak += 1
            if currentStreak > longestStreak {
                longestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
        
        saveStats()
    }
    
    func recordQuizSession(_ session: QuizSession) {
        let duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
        let entry = QuizHistoryEntry(
            date: session.startTime,
            questionsCount: session.totalQuestions,
            correctCount: session.correctCount,
            duration: duration
        )
        quizHistory.append(entry)
        
        // Keep only last 100 entries
        if quizHistory.count > 100 {
            quizHistory.removeFirst(quizHistory.count - 100)
        }
        
        saveStats()
    }
    
    func getWeakestCountries(limit: Int = 10) -> [Country] {
        let sortedStats = countryStats.values
            .filter { $0.timesAsked > 0 }
            .sorted { stat1, stat2 in
                // Sort by accuracy (ascending), then by times asked (descending)
                if stat1.accuracy != stat2.accuracy {
                    return stat1.accuracy < stat2.accuracy
                }
                return stat1.timesAsked > stat2.timesAsked
            }
        
        let weakCountryNames = sortedStats.prefix(limit).map { $0.countryName }
        return CountriesData.allCountries.filter { weakCountryNames.contains($0.name) }
    }
    
    func getNeverAskedCountries() -> [Country] {
        let askedCountries = Set(countryStats.keys)
        return CountriesData.allCountries.filter { !askedCountries.contains($0.name) }
    }
    
    func resetStats() {
        countryStats.removeAll()
        totalQuestionsAnswered = 0
        totalCorrectAnswers = 0
        currentStreak = 0
        longestStreak = 0
        quizHistory.removeAll()
        saveStats()
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(countryStats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
        
        userDefaults.set(totalQuestionsAnswered, forKey: totalQuestionsKey)
        userDefaults.set(totalCorrectAnswers, forKey: totalCorrectKey)
        userDefaults.set(currentStreak, forKey: currentStreakKey)
        userDefaults.set(longestStreak, forKey: longestStreakKey)
        
        if let encoded = try? JSONEncoder().encode(quizHistory) {
            userDefaults.set(encoded, forKey: quizHistoryKey)
        }
    }
    
    private func loadStats() {
        if let data = userDefaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode([String: CountryStats].self, from: data) {
            countryStats = decoded
        }
        
        totalQuestionsAnswered = userDefaults.integer(forKey: totalQuestionsKey)
        totalCorrectAnswers = userDefaults.integer(forKey: totalCorrectKey)
        currentStreak = userDefaults.integer(forKey: currentStreakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
        
        if let data = userDefaults.data(forKey: quizHistoryKey),
           let decoded = try? JSONDecoder().decode([QuizHistoryEntry].self, from: data) {
            quizHistory = decoded
        }
    }
}

struct QuizHistoryEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let questionsCount: Int
    let correctCount: Int
    let duration: TimeInterval
    
    var accuracy: Double {
        guard questionsCount > 0 else { return 0 }
        return Double(correctCount) / Double(questionsCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case date, questionsCount, correctCount, duration
    }
}
