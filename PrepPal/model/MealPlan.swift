import Foundation

struct MacroAchieved: Codable {
    let protein: Double
    let carbs: Double
    let fat: Double
    let calories: Double
}

struct Meal: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let description: String
    let calories: Int
    let macros: MacroGoal
    let mealType: MealType
    let ingredients: [String]
    let steps: [String]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
    
    enum MealType: String, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, calories, macros, mealType, ingredients, steps
    }
}
