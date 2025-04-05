import Foundation
import FirebaseFirestore

class PreferenceManager: ObservableObject {
    @Published private(set) var userPreferences: UserPreferences
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self.userPreferences = UserPreferences()
        loadPreferences()
    }
    
    // MARK: - Preference Updates
    func recordMealInteraction(meal: Meal, score: Double, context: String? = nil) {
        // Record ingredients
        for ingredient in meal.ingredients {
            userPreferences.updatePreference(
                category: .ingredients,
                value: ingredient,
                score: score,
                context: context
            )
        }
        
        // Could expand to record other aspects:
        // - Cooking methods
        // - Meal timing
        // - Portion sizes
        // - Cuisine types
    }
    
    func recordExplicitPreference(category: PreferenceCategory, value: String, liked: Bool) {
        userPreferences.updatePreference(
            category: category,
            value: value,
            score: liked ? 1.0 : -1.0,
            context: "Explicit user preference"
        )
    }
    
    func inferPreferencesFromMealPlan(_ mealPlan: WeeklyMealPlan, completion: Double) {
        // Infer preferences based on meal plan completion
        let score = (completion - 0.5) * 2 // Convert 0-1 completion to -1 to 1 score
        
        for dailyPlan in mealPlan.dailyPlans {
            for meal in dailyPlan.meals {
                recordMealInteraction(
                    meal: meal,
                    score: score,
                    context: "Meal plan completion: \(Int(completion * 100))%"
                )
            }
        }
    }
    
    // MARK: - Context Enhancement
    func enhanceContext(_ messages: [ChatMessage]) -> String {
        var enhancedContext = [String]()
        
        // Add critical preferences
        let criticalPrefs = userPreferences
            .getTopPreferences(category: .dietaryRestrictions)
            .filter { $0.confidence > 0.8 }
        if !criticalPrefs.isEmpty {
            enhancedContext.append("Critical Preferences:")
            enhancedContext.append(contentsOf: criticalPrefs.map { "- \($0.value)" })
        }
        
        // Add recent strong reactions
        let recentDislikes = userPreferences.getRecentNegativePreferences(days: 7)
        if !recentDislikes.isEmpty {
            enhancedContext.append("\nRecent Dislikes:")
            enhancedContext.append(contentsOf: recentDislikes.prefix(3).map { "- \($0.value)" })
        }
        
        // Add relevant preferences based on conversation
        let conversationContext = analyzeConversationContext(messages)
        if let relevantPrefs = getRelevantPreferences(for: conversationContext) {
            enhancedContext.append("\nRelevant Preferences:")
            enhancedContext.append(relevantPrefs)
        }
        
        return enhancedContext.joined(separator: "\n")
    }
    
    private func analyzeConversationContext(_ messages: [ChatMessage]) -> Set<PreferenceCategory> {
        var relevantCategories = Set<PreferenceCategory>()
        
        // Analyze last few messages for relevant preference categories
        for message in messages.suffix(5) {
            if message.content.localizedCaseInsensitiveContains("ingredient") {
                relevantCategories.insert(.ingredients)
            }
            if message.content.localizedCaseInsensitiveContains("cuisine") {
                relevantCategories.insert(.cuisines)
            }
            // Add more context analysis as needed
        }
        
        return relevantCategories
    }
    
    private func getRelevantPreferences(for categories: Set<PreferenceCategory>) -> String? {
        var relevantPrefs = [String]()
        
        for category in categories {
            let prefs = userPreferences.getTopPreferences(category: category, limit: 3)
            if !prefs.isEmpty {
                relevantPrefs.append("\(category.rawValue.capitalized):")
                relevantPrefs.append(contentsOf: prefs.map { "- \($0.value) (score: \(String(format: "%.2f", $0.score)))" })
            }
        }
        
        return relevantPrefs.isEmpty ? nil : relevantPrefs.joined(separator: "\n")
    }
    
    // MARK: - Storage
    private func loadPreferences() {
        Task {
            do {
                let docRef = db.collection("users").document(userId).collection("preferences").document("current")
                let document = try await docRef.getDocument()
                if let data = document.data() {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let preferences = try JSONDecoder().decode(UserPreferences.self, from: jsonData)
                    await MainActor.run {
                        self.userPreferences = preferences
                    }
                }
            } catch {
                print("Error loading preferences: \(error)")
            }
        }
    }
    
    func savePreferences() {
        Task {
            do {
                let data = try JSONEncoder().encode(userPreferences)
                if let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    try await db.collection("users").document(userId)
                        .collection("preferences").document("current")
                        .setData(dict)
                }
            } catch {
                print("Error saving preferences: \(error)")
            }
        }
    }
}