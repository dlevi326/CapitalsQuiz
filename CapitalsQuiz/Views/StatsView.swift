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
            ZStack {
                Theme.Gradients.backgroundTop.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with gradient text
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Statistics")
                                .font(Theme.Typography.largeTitle)
                                .foregroundStyle(Theme.Gradients.primary)
                            Text("Track your progress")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                        Spacer()
                        Button("Done") {
                            dismiss()
                        }
                        .font(Theme.Typography.headline)
                        .foregroundStyle(Theme.Gradients.primary)
                    }
                    .padding()
                    
                    // Animated Tab Picker
                    Picker("Stats View", selection: $selectedTab.animation(Theme.Animation.smooth)) {
                        Label("Overview", systemImage: "chart.bar.fill").tag(0)
                        Label("Countries", systemImage: "globe.americas.fill").tag(1)
                        Label("History", systemImage: "clock.fill").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, Theme.Spacing.sm)
                    
                    // Content with smooth transitions
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
            }
            .navigationBarHidden(true)
        }
    }
}

struct OverviewTab: View {
    @ObservedObject var statsManager: StatsManager
    @State private var selectedContinent: Continent? = nil
    
    private var filteredStats: (questions: Int, correct: Int, accuracy: Double) {
        if let continent = selectedContinent {
            let key = continent.rawValue
            if let cStats = statsManager.continentStats[key] {
                return (cStats.questionsAnswered, cStats.correctAnswers, cStats.accuracy)
            }
            return (0, 0, 0.0)
        } else {
            return (statsManager.totalQuestionsAnswered, statsManager.totalCorrectAnswers, statsManager.overallAccuracy)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.lg) {
                // Continent Filter Card
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    HStack {
                        Text("Filter by Region")
                            .font(Theme.Typography.headline)
                            .foregroundStyle(Theme.Gradients.primary)
                        Spacer()
                        Text(getEmoji(for: selectedContinent))
                            .font(.title2)
                    }
                    
                    Picker("Continent", selection: $selectedContinent.animation(Theme.Animation.smooth)) {
                        Text("🌎 All Continents").tag(nil as Continent?)
                        ForEach(Continent.allCases) { continent in
                            Text("\(getEmoji(for: continent)) \(continent.rawValue)").tag(continent as Continent?)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.Colors.primaryPurple)
                }
                .padding(Theme.Spacing.lg)
                .cardStyle()
                .padding(.horizontal)
                
                // Overall Stats
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text(selectedContinent == nil ? "Overall Performance" : "\(selectedContinent!.rawValue) Performance")
                        .font(Theme.Typography.title2)
                        .foregroundStyle(Theme.Gradients.primary)
                        .padding(.horizontal)
                    
                    VStack(spacing: Theme.Spacing.md) {
                        ModernStatsCard(
                            icon: "number",
                            gradient: Theme.Gradients.primary,
                            title: "Total Questions",
                            value: "\(filteredStats.questions)"
                        )
                        
                        ModernStatsCard(
                            icon: "checkmark.circle.fill",
                            gradient: Theme.Gradients.success,
                            title: "Correct Answers",
                            value: "\(filteredStats.correct)"
                        )
                        
                        ModernStatsCard(
                            icon: "target",
                            gradient: LinearGradient(colors: [Theme.Colors.primaryPurple, Theme.Colors.accentPink], startPoint: .leading, endPoint: .trailing),
                            title: "Accuracy",
                            value: String(format: "%.1f%%", filteredStats.accuracy * 100)
                        )
                        
                        if selectedContinent == nil {
                            ModernStatsCard(
                                icon: "flame.fill",
                                gradient: Theme.Gradients.warning,
                                title: "Current Streak",
                                value: "\(statsManager.currentStreak)"
                            )
                            
                            ModernStatsCard(
                                icon: "trophy.fill",
                                gradient: LinearGradient(colors: [Theme.Colors.accentYellow, Theme.Colors.warningOrange], startPoint: .leading, endPoint: .trailing),
                                title: "Best Streak",
                                value: "\(statsManager.longestStreak)"
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Countries Progress
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    Text("Learning Progress")
                        .font(Theme.Typography.title2)
                        .foregroundStyle(Theme.Gradients.primary)
                        .padding(.horizontal)
                    
                    let allCountriesFiltered = selectedContinent == nil ? CountriesData.allCountries : CountriesData.allCountries.filter { $0.continent == selectedContinent }
                    let totalCountries = allCountriesFiltered.count
                    let askedCountries = statsManager.countryStats.values.filter { stat in
                        allCountriesFiltered.contains { $0.name == stat.countryName }
                    }.count
                    let masteredCountries = statsManager.countryStats.values.filter { stat in
                        stat.accuracy >= 0.8 && stat.timesAsked >= 3 && allCountriesFiltered.contains { $0.name == stat.countryName }
                    }.count
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                        ProgressCard(icon: "globe.americas.fill", gradient: Theme.Gradients.primary, title: "Total", value: "\(totalCountries)")
                        ProgressCard(icon: "eye.fill", gradient: Theme.Gradients.success, title: "Seen", value: "\(askedCountries)")
                        ProgressCard(icon: "star.fill", gradient: LinearGradient(colors: [Theme.Colors.accentYellow, Theme.Colors.warningOrange], startPoint: .topLeading, endPoint: .bottomTrailing), title: "Mastered", value: "\(masteredCountries)")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func getEmoji(for continent: Continent?) -> String {
        guard let continent = continent else { return "🌎" }
        switch continent {
        case .africa: return "🌍"
        case .asia: return "🌏"
        case .europe: return "🇪🇺"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🗺️"
        case .oceania: return "🏝️"
        }
    }
}

struct CountriesTab: View {
    @ObservedObject var statsManager: StatsManager
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.accuracy
    @State private var selectedContinent: Continent? = nil
    
    enum SortOrder {
        case accuracy, name, timesAsked
    }
    
    var sortedCountries: [(country: Country, stats: CountryStats?)] {
        // Filter by continent first
        let continentFiltered = selectedContinent == nil ? CountriesData.allCountries : CountriesData.allCountries.filter { $0.continent == selectedContinent }
        
        let allCountriesWithStats = continentFiltered.map { country in
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
        VStack(spacing: Theme.Spacing.sm) {
            // Filters Card
            VStack(spacing: Theme.Spacing.md) {
                // Continent Filter
                Picker("Continent", selection: $selectedContinent.animation(Theme.Animation.smooth)) {
                    Text("🌎 All Continents").tag(nil as Continent?)
                    ForEach(Continent.allCases) { continent in
                        Text(getEmoji(for: continent) + " " + continent.rawValue).tag(continent as Continent?)
                    }
                }
                .pickerStyle(.menu)
                .tint(Theme.Colors.primaryPurple)
                
                // Sort Picker
                Picker("Sort By", selection: $sortOrder.animation(Theme.Animation.smooth)) {
                    Text("Accuracy").tag(SortOrder.accuracy)
                    Text("Name").tag(SortOrder.name)
                    Text("Times Asked").tag(SortOrder.timesAsked)
                }
                .pickerStyle(.segmented)
            }
            .padding(.horizontal)
            .padding(.top, Theme.Spacing.sm)
            
            List {
                ForEach(sortedCountries, id: \.country.id) { item in
                    ModernCountryStatsRow(country: item.country, stats: item.stats)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search countries or capitals")
        }
    }
    
    private func getEmoji(for continent: Continent) -> String {
        switch continent {
        case .africa: return "🌍"
        case .asia: return "🌏"
        case .europe: return "🇪🇺"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🗺️"
        case .oceania: return "🏝️"
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

struct ModernCountryStatsRow: View {
    let country: Country
    let stats: CountryStats?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(country.name)
                        .font(Theme.Typography.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    
                    Text(country.capital)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                
                Spacer()
                
                if let stats = stats {
                    if stats.accuracy >= 0.8 && stats.timesAsked >= 3 {
                        Text("✨")
                            .font(.title2)
                    }
                }
            }
            
            if let stats = stats {
                HStack(spacing: Theme.Spacing.md) {
                    HStack(spacing: 4) {
                        Image(systemName: "number")
                            .font(.caption)
                        Text("\(stats.timesAsked)")
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(Theme.Gradients.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.caption)
                        Text(String(format: "%.0f%%", stats.accuracy * 100))
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(stats.accuracy >= 0.8 ? Theme.Gradients.success : stats.accuracy >= 0.5 ? Theme.Gradients.warning : Theme.Gradients.error)
                }
            } else {
                Text("Not yet asked")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
    }
}

struct HistoryTab: View {
    @ObservedObject var statsManager: StatsManager
    @State private var emptyStateScale: CGFloat = 0.8
    
    var body: some View {
        Group {
            if statsManager.quizHistory.isEmpty {
                VStack(spacing: Theme.Spacing.lg) {
                    Spacer()
                    
                    Text("📚")
                        .font(.system(size: 100))
                        .scaleEffect(emptyStateScale)
                        .onAppear {
                            withAnimation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                .repeatForever(autoreverses: true)
                            ) {
                                emptyStateScale = 1.0
                            }
                        }
                    
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("No Quiz History Yet")
                            .font(Theme.Typography.title)
                            .foregroundStyle(Theme.Gradients.primary)
                        
                        Text("Complete a quiz to see your history here!")
                            .font(Theme.Typography.callout)
                            .foregroundStyle(Theme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
                .padding()
            } else {
                List {
                    ForEach(statsManager.quizHistory.reversed()) { entry in
                        ModernHistoryRow(entry: entry)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
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
            
            if let continent = entry.continent {
                Text(continent.rawValue)
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .padding(.vertical, 2)
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

struct ModernHistoryRow: View {
    let entry: QuizHistoryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(entry.date, style: .date)
                        .font(Theme.Typography.headline)
                    Text(entry.date, style: .time)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                
                Spacer()
                
                if let continent = entry.continent {
                    Text(getContinentEmoji(for: continent))
                        .font(.title2)
                }
            }
            
            HStack(spacing: Theme.Spacing.md) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("\(entry.correctCount)/\(entry.questionsCount)")
                        .font(Theme.Typography.caption)
                }
                .foregroundStyle(Theme.Gradients.success)
                
                HStack(spacing: 4) {
                    Image(systemName: "target")
                    Text(String(format: "%.0f%%", entry.accuracy * 100))
                        .font(Theme.Typography.caption)
                }
                .foregroundStyle(Theme.Gradients.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(formatDuration(entry.duration))
                        .font(Theme.Typography.caption)
                }
                .foregroundStyle(Theme.Gradients.warning)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, Theme.Spacing.xs)
    }
    
    private func getContinentEmoji(for continent: Continent) -> String {
        switch continent {
        case .africa: return "🌍"
        case .asia: return "🌏"
        case .europe: return "🇪🇺"
        case .northAmerica: return "🌎"
        case .southAmerica: return "🗺️"
        case .oceania: return "🏝️"
        }
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

struct ModernStatsCard: View {
    let icon: String
    let gradient: LinearGradient
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(gradient)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(value)
                    .font(Theme.Typography.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding(Theme.Spacing.lg)
        .gradientCardStyle(gradient: Theme.Gradients.quizCard)
    }
}

struct ProgressCard: View {
    let icon: String
    let gradient: LinearGradient
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(gradient)
            
            VStack(spacing: Theme.Spacing.xs) {
                Text(value)
                    .font(Theme.Typography.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .gradientCardStyle(gradient: Theme.Gradients.quizCard)
    }
}

#Preview {
    let statsManager = StatsManager()
    return StatsView(statsManager: statsManager)
}
