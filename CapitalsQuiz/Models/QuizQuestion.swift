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
    
    init(country: Country, wrongAnswers: [String]) {
        self.country = country
        self.correctAnswer = country.capital
        
        // Shuffle correct answer with wrong answers
        var allOptions = wrongAnswers
        allOptions.append(country.capital)
        self.options = allOptions.shuffled()
    }
}
