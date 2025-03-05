import Foundation

struct MacroAchieved {
    let protein: Double
    let carbs: Double
    let fat: Double
    let calories: Double
}

struct Meal: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let calories: Int
    let macros: MacroGoal // Update this to use MacroGoal
    let mealType: MealType
    let ingredients: [String] // Add this line
    let steps: [String] 
    
    enum MealType: String {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
}
struct MacroProgress {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var proteinProgress: Double { protein / 150.0 } // 150g goal
    var carbsProgress: Double { carbs / 200.0 }     // 200g goal
    var fatProgress: Double { fat / 67.0 }          // 67g goal
    
    var proteinStatus: String {
        if proteinProgress >= 0.9 { return "On Track" }
        if proteinProgress >= 0.7 { return "Review" }
        return "Low"
    }
    
    var carbsStatus: String {
        if carbsProgress >= 0.9 { return "On Track" }
        if carbsProgress >= 0.7 { return "Review" }
        return "Low"
    }
    
    var fatStatus: String {
        if fatProgress >= 0.9 { return "On Track" }
        if fatProgress >= 0.7 { return "Review" }
        return "Low"
    }
}

// End of file
