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
    let quizType: QuizType
    @State private var showingStats = false
    @State private var showingResetAlert = false
    @State private var selectedContinent: Continent? = nil
    @State private var globeScale: CGFloat = 1.0
    @State private var buttonPressed: String? = nil
    
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
            ZStack {
                // Background gradient
                Theme.Gradients.backgroundTop
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Header with animated globe
                        VStack(spacing: Theme.Spacing.md) {
                            Text(quizType.emoji)
                                .font(.system(size: 100))
                                .scaleEffect(globeScale)
                                .shadow(
                                    color: Theme.Colors.primaryBlue.opacity(0.3),
                                    radius: 20,
                                    x: 0,
                                    y: 10
                                )
                                .onAppear {
                                    withAnimation(
                                        .spring(response: 0.6, dampingFraction: 0.7)
                                    ) {
                                        globeScale = 1.05
                                    }
                                }
                            
                            Text(quizType.title)
                                .font(Theme.Typography.heroTitle)
                                .foregroundStyle(Theme.Gradients.primary)
                            
                            Text(quizType.subtitle)
                                .font(Theme.Typography.callout)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.xl)
                        
                        // Stats Overview Card
                        VStack(spacing: Theme.Spacing.md) {
                            HStack {
                                Text("Your Progress")
                                    .font(Theme.Typography.title3)
                                    .foregroundStyle(Theme.Gradients.primary)
                                Spacer()
                                Text("✨")
                                    .font(.title)
                            }
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                                StatCard(
                                    icon: "checkmark.circle.fill",
                                    label: "Answered",
                                    value: "\(statsManager.totalQuestionsAnswered)",
                                    gradient: Theme.Gradients.primary
                                )
                                
                                StatCard(
                                    icon: "target",
                                    label: "Accuracy",
                                    value: String(format: "%.1f%%", statsManager.overallAccuracy * 100),
                                    gradient: Theme.Gradients.success
                                )
                                
                                StatCard(
                                    icon: "flame.fill",
                                    label: "Current Streak",
                                    value: "\(statsManager.currentStreak)",
                                    gradient: Theme.Gradients.warning
                                )
                                
                                StatCard(
                                    icon: "trophy.fill",
                                    label: "Best Streak",
                                    value: "\(statsManager.longestStreak)",
                                    gradient: Theme.Gradients.celebration
                                )
                            }
                        }
                        .padding(Theme.Spacing.lg)
                        .gradientCardStyle(gradient: Theme.Gradients.quizCard)
                        .padding(.horizontal)
                        
                        // Continent Filter Card
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            HStack {
                                Text("Select Region")
                                    .font(Theme.Typography.title3)
                                    .foregroundStyle(Theme.Gradients.primary)
                                Spacer()
                                Text(continentEmoji(for: selectedContinent))
                                    .font(.title)
                            }
                            
                            Picker("Continent", selection: $selectedContinent) {
                                Text("🌎 All Continents").tag(nil as Continent?)
                                ForEach(Continent.allCases) { continent in
                                    Text("\(continentEmoji(for: continent)) \(continent.rawValue)").tag(continent as Continent?)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Theme.Colors.primaryPurple)
                            
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundStyle(Theme.Gradients.primary)
                                Text("\(questionCount) questions available")
                                    .font(Theme.Typography.caption)
                                    .foregroundStyle(Theme.Colors.textSecondary)
                            }
                        }
                        .padding(Theme.Spacing.lg)
                        .cardStyle()
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: Theme.Spacing.md) {
                            Button {
                                buttonPressed = "start"
                                withAnimation(Theme.Animation.bouncy) {
                                    buttonPressed = nil
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    quizManager.startQuiz(questionCount: questionCount, continent: selectedContinent)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Start Quiz")
                                }
                                .font(Theme.Typography.title2)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(Theme.Spacing.lg)
                                .background(Theme.Gradients.primary)
                                .cornerRadius(Theme.CornerRadius.md)
                                .shadow(
                                    color: Theme.Colors.primaryBlue.opacity(0.4),
                                    radius: Theme.Shadow.colored.radius,
                                    x: Theme.Shadow.colored.x,
                                    y: Theme.Shadow.colored.y
                                )
                            }
                            .scaleEffect(buttonPressed == "start" ? 0.95 : 1.0)
                            .sensoryFeedback(.impact, trigger: buttonPressed == "start")
                            
                            HStack(spacing: Theme.Spacing.md) {
                                Button {
                                    buttonPressed = "stats"
                                    withAnimation(Theme.Animation.bouncy) {
                                        buttonPressed = nil
                                    }
                                    showingStats = true
                                } label: {
                                    VStack(spacing: Theme.Spacing.sm) {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.title)
                                        Text("Statistics")
                                            .font(Theme.Typography.footnote)
                                    }
                                    .foregroundStyle(Theme.Gradients.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .cardStyle()
                                }
                                .scaleEffect(buttonPressed == "stats" ? 0.95 : 1.0)
                                .sensoryFeedback(.impact, trigger: buttonPressed == "stats")
                                
                                Button {
                                    buttonPressed = "reset"
                                    withAnimation(Theme.Animation.bouncy) {
                                        buttonPressed = nil
                                    }
                                    showingResetAlert = true
                                } label: {
                                    VStack(spacing: Theme.Spacing.sm) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .font(.title)
                                        Text("Reset")
                                            .font(Theme.Typography.footnote)
                                    }
                                    .foregroundStyle(Theme.Gradients.error)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .cardStyle()
                                }
                                .scaleEffect(buttonPressed == "reset" ? 0.95 : 1.0)
                                .sensoryFeedback(.impact, trigger: buttonPressed == "reset")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }
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
    
    private func continentEmoji(for continent: Continent?) -> String {
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

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(gradient)
            
            Text(value)
                .font(Theme.Typography.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(Theme.Typography.caption)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(Theme.CornerRadius.md)
    }
}

struct FloatingParticlesView: View {
    @State private var animate = false
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                for i in 0..<15 {
                    let x = (sin(now * 0.5 + Double(i)) * 0.5 + 0.5) * size.width
                    let y = (cos(now * 0.3 + Double(i) * 0.5) * 0.5 + 0.5) * size.height
                    let radius = 3.0 + sin(now * 0.7 + Double(i)) * 2
                    
                    let opacity = 0.2 + sin(now * 0.4 + Double(i)) * 0.1
                    
                    context.opacity = opacity
                    context.fill(
                        Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                        with: .color(i % 3 == 0 ? Theme.Colors.primaryBlue : i % 3 == 1 ? Theme.Colors.primaryPurple : Theme.Colors.accentTeal)
                    )
                }
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
    let quizManager = QuizManager(statsManager: statsManager, quizType: .countryCapitals)
    HomeView(quizManager: quizManager, statsManager: statsManager, quizType: .countryCapitals)
}

