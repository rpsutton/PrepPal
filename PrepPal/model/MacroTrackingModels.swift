import Foundation
import SwiftUI

// MARK: - Macro Status
enum MacroStatus: String {
    case onTrack = "On Track"
    case review = "Review"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .onTrack: return PrepPalTheme.Colors.success
        case .review: return PrepPalTheme.Colors.warning
        case .low: return PrepPalTheme.Colors.accentRed
        }
    }
}

// MARK: - Macro Progress
struct MacroProgress: Codable, Equatable {
    let protein: Double
    let carbs: Double
    let fat: Double
    let calories: Double
}

// MARK: - Daily Progress
struct DailyProgress {
    let achieved: MacroProgress
    let goal: MacroGoal
    let date: Date
    
    var remainingCalories: Int {
        goal.calories - Int(achieved.calories)
    }
    
    var calorieProgress: Double {
        Double(Int(achieved.calories)) / Double(goal.calories)
    }
    
    var proteinProgress: Double {
        achieved.protein / goal.protein
    }
    
    var carbsProgress: Double {
        achieved.carbs / goal.carbs
    }
    
    var fatProgress: Double {
        achieved.fat / goal.fat
    }
    
    func statusFor(progress: Double) -> MacroStatus {
        if progress >= 0.9 { return .onTrack }
        if progress >= 0.7 { return .review }
        return .low
    }
}

// MARK: - Weekly Progress
struct WeeklyProgress: Codable, Identifiable {
    var id: String = UUID().uuidString
    var date: Date
    var averageDailyCalories: Int
    var averageDailyProtein: Double
    var averageDailyCarbs: Double
    var averageDailyFat: Double
    var weightChange: Double?
    var completionRate: Double
    var notes: String = ""
}
