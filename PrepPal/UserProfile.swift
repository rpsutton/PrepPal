import Foundation
import Combine

// MARK: - User Profile
struct UserProfile: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var weight: Double = 70 // kg
    var heightCm: Double = 170 // cm
    var age: Int = 30
    var gender: String = "Unspecified"
    var activityLevel: ActivityLevel = .moderate
    var nutritionGoals: NutritionGoals?
    var dietaryRestrictions: [String] = []
    var allergies: [String] = []
    var dislikedIngredients: [String] = []
    var favoriteIngredients: [String] = []
    var goalUpdateDate: Date = Date()
    var weeklyProgressLog: [WeeklyProgress] = []
    
    mutating func generateNutritionGoals(goalType: NutritionGoals.GoalType, dietaryPattern: NutritionGoals.DietaryPattern) {
        self.nutritionGoals = NutritionGoals.createDefault(
            weight: weight,
            heightCm: heightCm,
            age: age,
            gender: gender,
            activityLevel: activityLevel,
            goalType: goalType,
            dietaryPattern: dietaryPattern
        )
        self.goalUpdateDate = Date()
    }
    
    mutating func logWeeklyProgress(_ progress: WeeklyProgress) {
        if weeklyProgressLog.count >= 12 {
            weeklyProgressLog.removeFirst()
        }
        weeklyProgressLog.append(progress)
    }
}

// MARK: - User Profile Manager
class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile
    private let userDefaultsKey = "UserProfile"
    
    init() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let loadedProfile = try? JSONDecoder().decode(UserProfile.self, from: savedData) {
            self.userProfile = loadedProfile
        } else {
            self.userProfile = UserProfile()
        }
    }
    
    func saveProfile() {
        if let encodedData = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    func updateNutritionGoals(goalType: NutritionGoals.GoalType, dietaryPattern: NutritionGoals.DietaryPattern) {
        userProfile.generateNutritionGoals(goalType: goalType, dietaryPattern: dietaryPattern)
        saveProfile()
    }
    
    func updateUserMetrics(weight: Double? = nil, heightCm: Double? = nil, age: Int? = nil, activityLevel: ActivityLevel? = nil) {
        if let weight = weight { userProfile.weight = weight }
        if let heightCm = heightCm { userProfile.heightCm = heightCm }
        if let age = age { userProfile.age = age }
        if let activityLevel = activityLevel { userProfile.activityLevel = activityLevel }
        saveProfile()
    }
    
    func updateDietaryPreferences(restrictions: [String]? = nil, allergies: [String]? = nil,
                                 disliked: [String]? = nil, favorites: [String]? = nil) {
        if let restrictions = restrictions { userProfile.dietaryRestrictions = restrictions }
        if let allergies = allergies { userProfile.allergies = allergies }
        if let disliked = disliked { userProfile.dislikedIngredients = disliked }
        if let favorites = favorites { userProfile.favoriteIngredients = favorites }
        saveProfile()
    }
    
    func logWeeklyProgress(_ progress: WeeklyProgress) {
        userProfile.logWeeklyProgress(progress)
        saveProfile()
    }
}
