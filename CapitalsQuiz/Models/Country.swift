//
//  Country.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

enum Continent: String, Codable, CaseIterable, Identifiable {
    case africa = "Africa"
    case asia = "Asia"
    case europe = "Europe"
    case northAmerica = "North America"
    case southAmerica = "South America"
    case oceania = "Oceania"
    
    var id: String { rawValue }
}

struct Country: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let capital: String
    let continent: Continent
    
    init(name: String, capital: String, continent: Continent) {
        self.id = name
        self.name = name
        self.capital = capital
        self.continent = continent
    }
}
