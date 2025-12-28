//
//  QuizType.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

enum QuizType: String, CaseIterable, Codable, Identifiable {
    case countryCapitals = "Country Capitals"
    case usStateCapitals = "US State Capitals"
    case countryFlags = "Country Flags"
    
    var id: String { rawValue }
    
    var tabIcon: String {
        switch self {
        case .countryCapitals: return "globe.americas.fill"
        case .usStateCapitals: return "map.fill"
        case .countryFlags: return "flag.fill"
        }
    }
    
    var tabLabel: String {
        switch self {
        case .countryCapitals: return "Capitals"
        case .usStateCapitals: return "US States"
        case .countryFlags: return "Flags"
        }
    }
    
    var title: String {
        switch self {
        case .countryCapitals: return "Capitals Quiz"
        case .usStateCapitals: return "US States Quiz"
        case .countryFlags: return "Flags Quiz"
        }
    }
    
    var subtitle: String {
        switch self {
        case .countryCapitals: return "Test your geography knowledge!"
        case .usStateCapitals: return "Master all 50 state capitals!"
        case .countryFlags: return "Identify country flags!"
        }
    }
    
    var emoji: String {
        switch self {
        case .countryCapitals: return "🌍"
        case .usStateCapitals: return "🇺🇸"
        case .countryFlags: return "🚩"
        }
    }
    
    var questionFormat: String {
        switch self {
        case .countryCapitals: return "What is the capital of"
        case .usStateCapitals: return "What is the capital of"
        case .countryFlags: return "Which country has this flag?"
        }
    }
    
    var isImplemented: Bool {
        switch self {
        case .countryCapitals: return true
        case .usStateCapitals: return false
        case .countryFlags: return false
        }
    }
}
