//
//  StatsManager.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

@MainActor
class StatsManager: ObservableObject {
    @Published private(set) var stats: [QuizType: QuizTypeStats] = [:]
    
    // Legacy properties for backward compatibility during migration
    @Published private(set) var countryStats: [String: CountryStats] = [:]
    @Published private(set) var continentStats: [String: ContinentStats] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let statsKeyV2 = "quizTypeStats_v2"
    
    // Legacy keys
    private let statsKey = "countryStats"
    private let continentStatsKey = "continentStats"
    private let totalQuestionsKey = "totalQuestions"
    private let totalCorrectKey = "totalCorrect"
    private let currentStreakKey = "currentStreak"
    private let longestStreakKey = "longestStreak"
    private let quizHistoryKey = "quizHistory"
    
    // Computed properties for Country Capitals quiz type
    var totalQuestionsAnswered: Int {
        stats[.countryCapitals]?.totalQuestions ?? 0
    }
    
    var totalCorrectAnswers: Int {
        stats[.countryCapitals]?.totalCorrect ?? 0
    }
    
    var currentStreak: Int {
        stats[.countryCapitals]?.currentStreak ?? 0
    }
    
    var longestStreak: Int {
        stats[.countryCapitals]?.longestStreak ?? 0
    }
    
    var quizHistory: [QuizHistoryEntry] {
        stats[.countryCapitals]?.quizHistory ?? []
    }
    
    var overallAccuracy: Double {
        stats[.countryCapitals]?.accuracy ?? 0
    }
    
    init() {
        loadStats()
    }
    
    func recordAnswer<T: Quizzable>(for item: T, isCorrect: Bool, quizType: QuizType, category: String) {
        var typeStats = stats[quizType] ?? QuizTypeStats(quizType: quizType)
        
        // Update item stats
        var itemStat = typeStats.itemStats[item.id] ?? ItemStats(
            itemId: item.id,
            itemName: item.displayName
        )
        itemStat.timesAsked += 1
        if isCorrect { itemStat.timesCorrect += 1 }
        itemStat.lastAsked = Date()
        typeStats.itemStats[item.id] = itemStat
        
        // Update category stats
        var catStats = typeStats.categoryStats[category] ?? CategoryStats(categoryName: category)
        catStats.questionsAnswered += 1
        if isCorrect { catStats.correctAnswers += 1 }
        typeStats.categoryStats[category] = catStats
        
        // Update overall stats
        typeStats.totalQuestions += 1
        if isCorrect {
            typeStats.totalCorrect += 1
            typeStats.currentStreak += 1
            typeStats.longestStreak = max(typeStats.currentStreak, typeStats.longestStreak)
        } else {
            typeStats.currentStreak = 0
        }
        
        stats[quizType] = typeStats
        saveStats()
    }
    
    // Legacy method for Country compatibility
    func recordAnswer(for country: Country, isCorrect: Bool) {
        recordAnswer(for: country, isCorrect: isCorrect, quizType: .countryCapitals, category: country.continent.rawValue)
        
        // Also update legacy stats for backward compatibility
        var legacyStats = countryStats[country.name] ?? CountryStats(countryName: country.name)
        legacyStats.timesAsked += 1
        if isCorrect { legacyStats.timesCorrect += 1 }
        legacyStats.lastAsked = Date()
        countryStats[country.name] = legacyStats
        
        let continentKey = country.continent.rawValue
        var cStats = continentStats[continentKey] ?? ContinentStats(continent: country.continent)
        cStats.questionsAnswered += 1
        if isCorrect { cStats.correctAnswers += 1 }
        continentStats[continentKey] = cStats
    }
    
    func recordQuizSession(_ session: QuizSession, quizType: QuizType) {
        guard !session.quitEarly else { return }
        
        var typeStats = stats[quizType] ?? QuizTypeStats(quizType: quizType)
        
        let duration = session.endTime?.timeIntervalSince(session.startTime) ?? 0
        let entry = QuizHistoryEntry(
            date: session.startTime,
            questionsCount: session.totalQuestions,
            correctCount: session.correctCount,
            duration: duration,
            continent: session.continent,
            quizType: quizType
        )
        typeStats.quizHistory.append(entry)
        
        // Keep only last 100 entries per quiz type
        if typeStats.quizHistory.count > 100 {
            typeStats.quizHistory.removeFirst(typeStats.quizHistory.count - 100)
        }
        
        stats[quizType] = typeStats
        saveStats()
    }
    
    // Legacy method for backward compatibility
    func recordQuizSession(_ session: QuizSession) {
        recordQuizSession(session, quizType: .countryCapitals)
    }
    
    func getWeakestCountries(limit: Int = 10) -> [Country] {
        guard let typeStats = stats[.countryCapitals] else { return [] }
        
        let sortedStats = typeStats.itemStats.values
            .filter { $0.timesAsked > 0 }
            .sorted { stat1, stat2 in
                if stat1.accuracy != stat2.accuracy {
                    return stat1.accuracy < stat2.accuracy
                }
                return stat1.timesAsked > stat2.timesAsked
            }
        
        let weakItemIds = sortedStats.prefix(limit).map { $0.itemId }
        return CountriesData.allCountries.filter { weakItemIds.contains($0.id) }
    }
    
    func getNeverAskedCountries() -> [Country] {
        guard let typeStats = stats[.countryCapitals] else {
            return CountriesData.allCountries
        }
        
        let askedIds = Set(typeStats.itemStats.keys)
        return CountriesData.allCountries.filter { !askedIds.contains($0.id) }
    }
    
    func resetStats(for quizType: QuizType? = nil) {
        if let quizType = quizType {
            stats[quizType] = QuizTypeStats(quizType: quizType)
        } else {
            stats.removeAll()
            countryStats.removeAll()
            continentStats.removeAll()
        }
        saveStats()
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            userDefaults.set(encoded, forKey: statsKeyV2)
        }
    }
    
    private func loadStats() {
        // Try to load new format first
        if let data = userDefaults.data(forKey: statsKeyV2),
           let decoded = try? JSONDecoder().decode([QuizType: QuizTypeStats].self, from: data) {
            stats = decoded
            return
        }
        
        // Migrate from legacy format
        migrateLegacyStats()
    }
    
    private func migrateLegacyStats() {
        var countryCapitalsStats = QuizTypeStats(quizType: .countryCapitals)
        
        // Migrate country stats
        if let data = userDefaults.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode([String: CountryStats].self, from: data) {
            countryStats = decoded
            
            for (_, countryStatData) in decoded {
                let itemStat = ItemStats(
                    itemId: countryStatData.countryName,
                    itemName: countryStatData.countryName
                )
                var mutableStat = itemStat
                mutableStat.timesAsked = countryStatData.timesAsked
                mutableStat.timesCorrect = countryStatData.timesCorrect
                mutableStat.lastAsked = countryStatData.lastAsked
                countryCapitalsStats.itemStats[countryStatData.countryName] = mutableStat
            }
        }
        
        // Migrate continent stats
        if let data = userDefaults.data(forKey: continentStatsKey),
           let decoded = try? JSONDecoder().decode([String: ContinentStats].self, from: data) {
            continentStats = decoded
            
            for (key, continentStatData) in decoded {
                var catStat = CategoryStats(categoryName: key)
                catStat.questionsAnswered = continentStatData.questionsAnswered
                catStat.correctAnswers = continentStatData.correctAnswers
                countryCapitalsStats.categoryStats[key] = catStat
            }
        }
        
        // Migrate overall stats
        countryCapitalsStats.totalQuestions = userDefaults.integer(forKey: totalQuestionsKey)
        countryCapitalsStats.totalCorrect = userDefaults.integer(forKey: totalCorrectKey)
        countryCapitalsStats.currentStreak = userDefaults.integer(forKey: currentStreakKey)
        countryCapitalsStats.longestStreak = userDefaults.integer(forKey: longestStreakKey)
        
        // Migrate quiz history
        if let data = userDefaults.data(forKey: quizHistoryKey),
           let decoded = try? JSONDecoder().decode([QuizHistoryEntry].self, from: data) {
            // Add quizType to legacy entries
            countryCapitalsStats.quizHistory = decoded.map { entry in
                var newEntry = entry
                newEntry.quizType = .countryCapitals
                return newEntry
            }
        }
        
        stats[.countryCapitals] = countryCapitalsStats
        saveStats()
    }
}

struct QuizHistoryEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let questionsCount: Int
    let correctCount: Int
    let duration: TimeInterval
    let continent: Continent?
    var quizType: QuizType?
    
    var accuracy: Double {
        guard questionsCount > 0 else { return 0 }
        return Double(correctCount) / Double(questionsCount)
    }
    
    enum CodingKeys: String, CodingKey {
        case date, questionsCount, correctCount, duration, continent, quizType
    }
}
