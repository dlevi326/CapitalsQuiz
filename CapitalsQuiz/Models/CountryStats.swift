//
//  CountryStats.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

// Generic item stats for any quizzable type
struct ItemStats: Codable {
    let itemId: String
    let itemName: String
    var timesAsked: Int
    var timesCorrect: Int
    var lastAsked: Date?
    
    var accuracy: Double {
        guard timesAsked > 0 else { return 0 }
        return Double(timesCorrect) / Double(timesAsked)
    }
    
    init(itemId: String, itemName: String) {
        self.itemId = itemId
        self.itemName = itemName
        self.timesAsked = 0
        self.timesCorrect = 0
        self.lastAsked = nil
    }
}

// Legacy CountryStats for backward compatibility
struct CountryStats: Codable {
    let countryName: String
    var timesAsked: Int
    var timesCorrect: Int
    var lastAsked: Date?
    
    var accuracy: Double {
        guard timesAsked > 0 else { return 0 }
        return Double(timesCorrect) / Double(timesAsked)
    }
    
    init(countryName: String) {
        self.countryName = countryName
        self.timesAsked = 0
        self.timesCorrect = 0
        self.lastAsked = nil
    }
}

struct ContinentStats: Codable {
    let continent: Continent
    var questionsAnswered: Int
    var correctAnswers: Int
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
    
    init(continent: Continent) {
        self.continent = continent
        self.questionsAnswered = 0
        self.correctAnswers = 0
    }
}

// Generic category stats for any quiz type
struct CategoryStats: Codable {
    let categoryName: String
    var questionsAnswered: Int
    var correctAnswers: Int
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
    
    init(categoryName: String) {
        self.categoryName = categoryName
        self.questionsAnswered = 0
        self.correctAnswers = 0
    }
}

struct QuizTypeStats: Codable {
    let quizType: QuizType
    var totalQuestions: Int
    var totalCorrect: Int
    var currentStreak: Int
    var longestStreak: Int
    var itemStats: [String: ItemStats] // itemId: stats
    var categoryStats: [String: CategoryStats] // category: stats
    var quizHistory: [QuizHistoryEntry]
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalQuestions)
    }
    
    init(quizType: QuizType) {
        self.quizType = quizType
        self.totalQuestions = 0
        self.totalCorrect = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.itemStats = [:]
        self.categoryStats = [:]
        self.quizHistory = []
    }
}

