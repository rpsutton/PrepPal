import Foundation
import SwiftUI
import Combine

// MARK: - Nutrition Goal Models
struct NutritionGoals: Codable, Equatable {
    var macros: MacroGoal
    var calorieGoal: Int
    var targetProteinPerKg: Double
    var targetCarbs: Int
    var targetFat: Int
    var goalType: GoalType
    var dietaryPattern: DietaryPattern
    
    enum GoalType: String, Codable, CaseIterable, Identifiable {
        case weightLoss = "Weight Loss"
        case maintenance = "Maintenance"
        case muscleGain = "Muscle Gain"
        case athletic = "Athletic Performance"
        case custom = "Custom"
        
        var id: String { self.rawValue }
        
        var description: String {
            switch self {
            case .weightLoss: return "Reduce body fat while preserving muscle"
            case .maintenance: return "Maintain current weight and body composition"
            case .muscleGain: return "Build muscle with moderate fat gain"
            case .athletic: return "Optimize fuel for training and recovery"
            case .custom: return "Fully customized macronutrient targets"
            }
        }
    }
    
    enum DietaryPattern: String, Codable, CaseIterable, Identifiable {
        case balanced = "Balanced"
        case lowCarb = "Low Carb"
        case keto = "Ketogenic"
        case highProtein = "High Protein"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case paleo = "Paleo"
        case mediterranean = "Mediterranean"
        
        var id: String { self.rawValue }
        
        var macroDistribution: (protein: Double, carbs: Double, fat: Double) {
            switch self {
            case .balanced: return (0.25, 0.50, 0.25)
            case .lowCarb: return (0.30, 0.30, 0.40)
            case .keto: return (0.25, 0.05, 0.70)
            case .highProtein: return (0.40, 0.40, 0.20)
            case .vegetarian, .vegan: return (0.20, 0.60, 0.20)
            case .paleo: return (0.30, 0.25, 0.45)
            case .mediterranean: return (0.25, 0.45, 0.30)
            }
        }
    }
    
    // Create default goals based on user metrics and preferences
    static func createDefault(
        weight: Double,
        heightCm: Double,
        age: Int,
        gender: String,
        activityLevel: ActivityLevel,
        goalType: GoalType,
        dietaryPattern: DietaryPattern
    ) -> NutritionGoals {
        // Calculate BMR using Mifflin-St Jeor Equation
        let bmr: Double
        if gender.lowercased() == "male" {
            bmr = 10 * weight + 6.25 * heightCm - 5 * Double(age) + 5
        } else {
            bmr = 10 * weight + 6.25 * heightCm - 5 * Double(age) - 161
        }
        
        // Apply activity multiplier
        let tdee = bmr * activityLevel.multiplier
        
        // Adjust calories based on goal
        var adjustedCalories = tdee
        switch goalType {
        case .weightLoss:
            adjustedCalories = tdee * 0.8 // 20% deficit
        case .maintenance:
            adjustedCalories = tdee
        case .muscleGain:
            adjustedCalories = tdee * 1.1 // 10% surplus
        case .athletic:
            adjustedCalories = tdee * 1.15 // 15% surplus
        case .custom:
            adjustedCalories = tdee // Will be manually adjusted
        }
        
        // Calculate protein target based on weight and goal
        let proteinPerKg: Double
        switch goalType {
        case .weightLoss: proteinPerKg = 2.0 // Higher protein for muscle preservation
        case .maintenance: proteinPerKg = 1.6
        case .muscleGain: proteinPerKg = 1.8
        case .athletic: proteinPerKg = 2.2
        case .custom: proteinPerKg = 1.6 // Default
        }
        
        // Calculate macros based on dietary pattern
        let proteinCals = weight * proteinPerKg * 4
        let distribution = dietaryPattern.macroDistribution
        
        // Remaining calories after protein
        let remainingCals = adjustedCalories - proteinCals
        let carbsCals = remainingCals * distribution.carbs / (distribution.carbs + distribution.fat)
        let fatCals = remainingCals * distribution.fat / (distribution.carbs + distribution.fat)
        
        let proteinGrams = weight * proteinPerKg
        let carbsGrams = carbsCals / 4
        let fatGrams = fatCals / 9
        
        return NutritionGoals(
            macros: MacroGoal(
                protein: proteinGrams,
                carbs: carbsGrams,
                fat: fatGrams,
                calories: Int(adjustedCalories)
            ),
            calorieGoal: Int(adjustedCalories),
            targetProteinPerKg: proteinPerKg,
            targetCarbs: Int(carbsGrams),
            targetFat: Int(fatGrams),
            goalType: goalType,
            dietaryPattern: dietaryPattern
        )
    }
}

enum ActivityLevel: String, Codable, CaseIterable, Identifiable {
    case sedentary = "Sedentary (little or no exercise)"
    case light = "Lightly active (light exercise 1-3 days/week)"
    case moderate = "Moderately active (moderate exercise 3-5 days/week)"
    case active = "Active (hard exercise 6-7 days/week)"
    case veryActive = "Very active (hard daily exercise & physical job)"
    
    var id: String { self.rawValue }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .light: return 1.375
        case .moderate: return 1.55
        case .active: return 1.725
        case .veryActive: return 1.9
        }
    }
}

// MARK: - User Profile Model
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
    
    // Track weekly progress
    var weeklyProgressLog: [WeeklyProgress] = []
    
    // Create nutrition goals based on current profile
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
    
    // Add a new weekly progress entry
    mutating func logWeeklyProgress(_ progress: WeeklyProgress) {
        // Keep only the last 12 weeks of history
        if weeklyProgressLog.count >= 12 {
            weeklyProgressLog.removeFirst()
        }
        weeklyProgressLog.append(progress)
    }
}

struct MacroGoal: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    let protein: Double
    let carbs: Double
    let fat: Double
    let calories: Int
}

// MARK: - Progress Tracking
struct WeeklyProgress: Codable, Identifiable {
    var id: String = UUID().uuidString
    var date: Date
    var averageDailyCalories: Int
    var averageDailyProtein: Double
    var averageDailyCarbs: Double
    var averageDailyFat: Double
    var weightChange: Double? // Optional weight update
    var completionRate: Double // % of planned meals actually prepared
    var notes: String = ""
}

// MARK: - UserProfileManager
class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile
    private let userDefaultsKey = "UserProfile"
    
    init() {
        // Load from UserDefaults or create a new profile
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
        if let weight = weight {
            userProfile.weight = weight
        }
        if let heightCm = heightCm {
            userProfile.heightCm = heightCm
        }
        if let age = age {
            userProfile.age = age
        }
        if let activityLevel = activityLevel {
            userProfile.activityLevel = activityLevel
        }
        saveProfile()
    }
    
    func updateDietaryPreferences(restrictions: [String]? = nil, allergies: [String]? = nil,
                                 disliked: [String]? = nil, favorites: [String]? = nil) {
        if let restrictions = restrictions {
            userProfile.dietaryRestrictions = restrictions
        }
        if let allergies = allergies {
            userProfile.allergies = allergies
        }
        if let disliked = disliked {
            userProfile.dislikedIngredients = disliked
        }
        if let favorites = favorites {
            userProfile.favoriteIngredients = favorites
        }
        saveProfile()
    }
    
    func logWeeklyProgress(_ progress: WeeklyProgress) {
        userProfile.logWeeklyProgress(progress)
        saveProfile()
    }
}
