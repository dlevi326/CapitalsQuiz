//
//  QuizQuestion.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

struct QuizQuestion: Identifiable {
    let id = UUID()
    let country: Country
    let correctAnswer: String
    let options: [String]
    let questionFormat: String
    
    init(country: Country, wrongAnswers: [String], questionFormat: String = "What is the capital of") {
        self.country = country
        self.correctAnswer = country.capital
        self.questionFormat = questionFormat
        
        // Shuffle correct answer with wrong answers
        var allOptions = wrongAnswers
        allOptions.append(country.capital)
        self.options = allOptions.shuffled()
    }
    
    var questionText: String {
        "\(questionFormat) \(country.name)?"
    }
}

