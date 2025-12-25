//
//  HomeView.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var quizManager: QuizManager
    @ObservedObject var statsManager: StatsManager
    @State private var showingStats = false
    @State private var showingResetAlert = false
    @State private var selectedContinent: Continent? = nil
    
    private var questionCount: Int {
        let availableCountries = if let continent = selectedContinent {
            CountriesData.allCountries.filter { $0.continent == continent }
        } else {
            CountriesData.allCountries
        }
        return min(10, max(5, availableCountries.count))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "globe.americas.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("Capitals Quiz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .padding(.top, 50)
                
                // Stats Overview
                VStack(spacing: 15) {
                    StatRow(label: "Questions Answered", value: "\(statsManager.totalQuestionsAnswered)")
                    StatRow(label: "Accuracy", value: String(format: "%.1f%%", statsManager.overallAccuracy * 100))
                    StatRow(label: "Current Streak", value: "\(statsManager.currentStreak)")
                    StatRow(label: "Best Streak", value: "\(statsManager.longestStreak)")
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                Spacer()
                
                // Continent Filter
                VStack(alignment: .leading, spacing: 10) {
                    Text("Select Continent")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Continent", selection: $selectedContinent) {
                        Text("All Continents").tag(nil as Continent?)
                        ForEach(Continent.allCases) { continent in
                            Text(continent.rawValue).tag(continent as Continent?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    
                    Text("\(questionCount) questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                
                // Buttons
                VStack(spacing: 15) {
                    Button {
                        quizManager.startQuiz(questionCount: questionCount, continent: selectedContinent)
                    } label: {
                        Label("Start Quiz", systemImage: "play.fill")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(15)
                    }
                    
                    Button {
                        showingStats = true
                    } label: {
                        Label("View Statistics", systemImage: "chart.bar.fill")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .systemGray5))
                            .foregroundStyle(.primary)
                            .cornerRadius(15)
                    }
                    
                    Button {
                        showingResetAlert = true
                    } label: {
                        Label("Reset Stats", systemImage: "arrow.counterclockwise")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .systemGray5))
                            .foregroundStyle(.red)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingStats) {
                StatsView(statsManager: statsManager)
            }
            .alert("Reset Statistics", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    statsManager.resetStats()
                }
            } message: {
                Text("Are you sure you want to reset all your statistics? This cannot be undone.")
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    let statsManager = StatsManager()
    let quizManager = QuizManager(statsManager: statsManager)
    return HomeView(quizManager: quizManager, statsManager: statsManager)
}
