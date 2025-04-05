import Foundation

// MARK: - Preference Types
enum PreferenceCategory: String, Codable, CaseIterable {
    case ingredients
    case cuisines
    case mealTimes
    case cookingMethods
    case portionSizes
    case flavors
    case dietaryRestrictions
    case allergies
}

// MARK: - Preference Item
struct PreferenceItem: Codable, Identifiable {
    let id: UUID
    let category: PreferenceCategory
    let value: String
    var score: Double // -1.0 to 1.0
    var confidence: Double // 0.0 to 1.0
    var lastUpdated: Date
    var occurrences: Int
    
    init(category: PreferenceCategory, value: String) {
        self.id = UUID()
        self.category = category
        self.value = value
        self.score = 0.0
        self.confidence = 0.0
        self.lastUpdated = Date()
        self.occurrences = 1
    }
    
    mutating func updateScore(_ newScore: Double, weight: Double = 1.0) {
        // Weighted moving average
        let alpha = min(max(0.1, weight), 1.0)
        score = score * (1 - alpha) + newScore * alpha
        occurrences += 1
        confidence = min(Double(occurrences) / 10.0, 1.0) // Confidence builds over time
        lastUpdated = Date()
    }
}

// MARK: - User Preferences
class UserPreferences: ObservableObject, Codable {
    @Published var preferences: [PreferenceCategory: [PreferenceItem]]
    @Published var recentInteractions: [PreferenceInteraction]
    let maxInteractionHistory: Int = 100
    
    enum CodingKeys: String, CodingKey {
        case preferences
        case recentInteractions
    }
    
    init() {
        self.preferences = [:]
        self.recentInteractions = []
        PreferenceCategory.allCases.forEach { category in
            preferences[category] = []
        }
    }
    
    // MARK: - Preference Management
    func updatePreference(category: PreferenceCategory, value: String, score: Double, context: String? = nil) {
        let interaction = PreferenceInteraction(
            category: category,
            value: value,
            score: score,
            context: context
        )
        
        addInteraction(interaction)
        
        if var items = preferences[category],
           let index = items.firstIndex(where: { $0.value == value }) {
            items[index].updateScore(score)
            preferences[category] = items
        } else {
            var newItem = PreferenceItem(category: category, value: value)
            newItem.updateScore(score)
            preferences[category, default: []].append(newItem)
        }
    }
    
    func addInteraction(_ interaction: PreferenceInteraction) {
        recentInteractions.append(interaction)
        if recentInteractions.count > maxInteractionHistory {
            recentInteractions.removeFirst()
        }
    }
    
    // MARK: - Preference Analysis
    func getTopPreferences(category: PreferenceCategory, limit: Int = 5) -> [PreferenceItem] {
        return preferences[category, default: []]
            .filter { $0.confidence > 0.3 } // Only return items with decent confidence
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecentNegativePreferences(days: Int = 30) -> [PreferenceItem] {
        let cutoffDate = Date().addingTimeInterval(-Double(days * 24 * 60 * 60))
        return preferences.values.flatMap { $0 }
            .filter { $0.lastUpdated > cutoffDate && $0.score < 0 }
            .sorted { $0.score < $1.score }
    }
    
    // MARK: - Context Generation
    func generateContext() -> String {
        var context: [String] = []
        
        // Add strong preferences (both positive and negative)
        for category in PreferenceCategory.allCases {
            let topLikes = getTopPreferences(category: category, limit: 3)
                .filter { $0.score > 0.7 }
                .map { $0.value }
            
            if !topLikes.isEmpty {
                context.append("\(category.rawValue) preferences: \(topLikes.joined(separator: ", "))")
            }
            
            let strongDislikes = preferences[category, default: []]
                .filter { $0.score < -0.7 && $0.confidence > 0.5 }
                .map { $0.value }
            
            if !strongDislikes.isEmpty {
                context.append("Avoids \(category.rawValue): \(strongDislikes.joined(separator: ", "))")
            }
        }
        
        return context.joined(separator: "\n")
    }
    
    // MARK: - Codable Implementation
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        preferences = try container.decode([PreferenceCategory: [PreferenceItem]].self, forKey: .preferences)
        recentInteractions = try container.decode([PreferenceInteraction].self, forKey: .recentInteractions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(preferences, forKey: .preferences)
        try container.encode(recentInteractions, forKey: .recentInteractions)
    }
}

// MARK: - Preference Interaction
struct PreferenceInteraction: Codable {
    let timestamp: Date
    let category: PreferenceCategory
    let value: String
    let score: Double
    let context: String?
    
    init(category: PreferenceCategory, value: String, score: Double, context: String? = nil) {
        self.timestamp = Date()
        self.category = category
        self.value = value
        self.score = score
        self.context = context
    }
}
