import SwiftUI

// MARK: - Supporting Models for Nutrition Goal Setting

// Temporary data storage for the goal setting process
struct TemporaryUserData {
    var weight: Double?
    var heightCm: Double?
    var age: Int?
    var gender: String?
    var activityLevel: ActivityLevel?
    var goalType: NutritionGoals.GoalType?
    var dietaryPattern: NutritionGoals.DietaryPattern?
}

// Steps in the goal setting process
enum GoalSettingStep {
    case welcome
    case basicInfo
    case goalType
    case dietaryPattern
    case review
}
