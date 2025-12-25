//
//  Country.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

struct Country: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let capital: String
    
    init(name: String, capital: String) {
        self.id = name
        self.name = name
        self.capital = capital
    }
}
