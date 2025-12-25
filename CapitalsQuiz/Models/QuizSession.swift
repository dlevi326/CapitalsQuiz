//
//  QuizSession.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

struct QuizSession {
    let startTime: Date
    var endTime: Date?
    var questions: [QuizQuestion]
    var currentQuestionIndex: Int
    var answers: [String: Bool] // countryName: isCorrect
    let continent: Continent? // Track which continent filter was used
    var quitEarly: Bool = false
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var correctCount: Int {
        answers.values.filter { $0 }.count
    }
    
    var totalQuestions: Int {
        questions.count
    }
    
    var isComplete: Bool {
        quitEarly || currentQuestionIndex >= questions.count
    }
    
    init(questions: [QuizQuestion], continent: Continent? = nil) {
        self.startTime = Date()
        self.questions = questions
        self.currentQuestionIndex = 0
        self.answers = [:]
        self.continent = continent
    }
    
    mutating func submitAnswer(_ answer: String) -> Bool {
        guard let question = currentQuestion else { return false }
        
        let isCorrect = answer == question.correctAnswer
        answers[question.country.name] = isCorrect
        currentQuestionIndex += 1
        
        if isComplete {
            endTime = Date()
        }
        
        return isCorrect
    }
}
