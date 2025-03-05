import SwiftUI

// MARK: - Recipe Section Enum
enum RecipeSection {
    case description, ingredients, instructions
}

// MARK: - Modification Type Enum
enum ModificationType: String, CaseIterable, Identifiable {
    case macros = "Adjust Macros"
    case ingredients = "Swap Ingredients"
    case flavor = "Change Flavor Profile"
    case dietary = "Dietary Restrictions"
    case servings = "Adjust Servings"
    
    var id: String { self.rawValue }
    
    var prompt: String {
        switch self {
        case .macros:
            return "Would you like more protein, fewer carbs, or lower fat?"
        case .ingredients:
            return "Which ingredient would you like to swap out?"
        case .flavor:
            return "What flavor profile are you looking for? (e.g., spicy, sweet, Mediterranean)"
        case .dietary:
            return "What dietary restriction should I accommodate? (e.g., gluten-free, vegan)"
        case .servings:
            return "How many servings would you like to make?"
        }
    }
    
    var icon: String {
        switch self {
        case .macros: return "chart.bar"
        case .ingredients: return "arrow.triangle.swap"
        case .flavor: return "flame"
        case .dietary: return "leaf"
        case .servings: return "person.2"
        }
    }
}

