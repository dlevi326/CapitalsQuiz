//
//  Quizzable.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import Foundation

protocol Quizzable: Identifiable, Codable, Hashable {
    var id: String { get }
    var displayName: String { get }
    var answer: String { get }
    var category: String { get }
}
