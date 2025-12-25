//
//  StatsView.swift
//  CapitalsQuiz
//
//  Created on 12/25/25.
//

import SwiftUI

struct StatsView: View {
    @ObservedObject var statsManager: StatsManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                // Tab Picker
                Picker("Stats View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Countries").tag(1)
                    Text("History").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    OverviewTab(statsManager: statsManager)
                        .tag(0)
                    
                    CountriesTab(statsManager: statsManager)
                        .tag(1)
                    
                    HistoryTab(statsManager: statsManager)
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct OverviewTab: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("Overall Performance")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        StatsCard(
                            icon: "number",
                            color: .blue,
                            title: "Total Questions",
                            value: "\(statsManager.totalQuestionsAnswered)"
                        )
                        
                        StatsCard(
                            icon: "checkmark.circle.fill",
                            color: .green,
                            title: "Correct Answers",
                            value: "\(statsManager.totalCorrectAnswers)"
                        )
                        
                        StatsCard(
                            icon: "percent",
                            color: .purple,
                            title: "Overall Accuracy",
                            value: String(format: "%.1f%%", statsManager.overallAccuracy * 100)
                        )
                        
                        StatsCard(
                            icon: "flame.fill",
                            color: .orange,
                            title: "Current Streak",
                            value: "\(statsManager.currentStreak)"
                        )
                        
                        StatsCard(
                            icon: "trophy.fill",
                            color: .yellow,
                            title: "Best Streak",
                            value: "\(statsManager.longestStreak)"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Countries Progress
                VStack(alignment: .leading, spacing: 15) {
                    Text("Progress")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    let totalCountries = CountriesData.allCountries.count
                    let askedCountries = statsManager.countryStats.count
                    let masteredCountries = statsManager.countryStats.values.filter { $0.accuracy >= 0.8 && $0.timesAsked >= 3 }.count
                    
                    VStack(spacing: 12) {
                        StatsCard(
                            icon: "globe.americas.fill",
                            color: .blue,
                            title: "Total Countries",
                            value: "\(totalCountries)"
                        )
                        
                        StatsCard(
                            icon: "eye.fill",
                            color: .green,
                            title: "Countries Seen",
                            value: "\(askedCountries)"
                        )
                        
                        StatsCard(
                            icon: "star.fill",
                            color: .yellow,
                            title: "Countries Mastered",
                            value: "\(masteredCountries)"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

struct CountriesTab: View {
    @ObservedObject var statsManager: StatsManager
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.accuracy
    
    enum SortOrder {
        case accuracy, name, timesAsked
    }
    
    var sortedCountries: [(country: Country, stats: CountryStats?)] {
        let allCountriesWithStats = CountriesData.allCountries.map { country in
            (country: country, stats: statsManager.countryStats[country.name])
        }
        
        let filtered = searchText.isEmpty ? allCountriesWithStats : allCountriesWithStats.filter {
            $0.country.name.localizedCaseInsensitiveContains(searchText) ||
            $0.country.capital.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { item1, item2 in
            switch sortOrder {
            case .accuracy:
                let acc1 = item1.stats?.accuracy ?? 0
                let acc2 = item2.stats?.accuracy ?? 0
                return acc1 < acc2
            case .name:
                return item1.country.name < item2.country.name
            case .timesAsked:
                let times1 = item1.stats?.timesAsked ?? 0
                let times2 = item2.stats?.timesAsked ?? 0
                return times1 > times2
            }
        }
    }
    
    var body: some View {
        VStack {
            // Sort Picker
            Picker("Sort By", selection: $sortOrder) {
                Text("Accuracy").tag(SortOrder.accuracy)
                Text("Name").tag(SortOrder.name)
                Text("Times Asked").tag(SortOrder.timesAsked)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            List {
                ForEach(sortedCountries, id: \.country.id) { item in
                    CountryStatsRow(country: item.country, stats: item.stats)
                }
            }
            .searchable(text: $searchText, prompt: "Search countries or capitals")
        }
    }
}

struct CountryStatsRow: View {
    let country: Country
    let stats: CountryStats?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(country.name)
                .font(.headline)
            
            Text(country.capital)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let stats = stats {
                HStack(spacing: 15) {
                    Label("\(stats.timesAsked)", systemImage: "number")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    Label(String(format: "%.0f%%", stats.accuracy * 100), systemImage: "percent")
                        .font(.caption)
                        .foregroundStyle(stats.accuracy >= 0.8 ? .green : stats.accuracy >= 0.5 ? .orange : .red)
                    
                    if stats.accuracy >= 0.8 && stats.timesAsked >= 3 {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
                .padding(.top, 2)
            } else {
                Text("Not yet asked")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HistoryTab: View {
    @ObservedObject var statsManager: StatsManager
    
    var body: some View {
        List {
            if statsManager.quizHistory.isEmpty {
                Text("No quiz history yet")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(statsManager.quizHistory.reversed()) { entry in
                    HistoryRow(entry: entry)
                }
            }
        }
    }
}

struct HistoryRow: View {
    let entry: QuizHistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.date, style: .date)
                    .font(.headline)
                Spacer()
                Text(entry.date, style: .time)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 15) {
                Label("\(entry.correctCount)/\(entry.questionsCount)", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                
                Label(String(format: "%.0f%%", entry.accuracy * 100), systemImage: "percent")
                    .font(.caption)
                    .foregroundStyle(.blue)
                
                Label(formatDuration(entry.duration), systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct StatsCard: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let statsManager = StatsManager()
    return StatsView(statsManager: statsManager)
}
