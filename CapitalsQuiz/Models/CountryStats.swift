//
//  CountryStats.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

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
