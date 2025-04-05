import Foundation

struct DailyMealPlan: Identifiable, Codable {
    let id = UUID()
    let day: String
    let meals: [Meal]
    let macros: MacroGoal
    let achievedMacros: MacroAchieved
    let isToday: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, day, meals, macros, achievedMacros, isToday
    }
}

struct WeeklyMealPlan: Codable {
    let dailyPlans: [DailyMealPlan]
    
    static func createSampleData() -> WeeklyMealPlan {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: Date())

        return WeeklyMealPlan(dailyPlans: [
            DailyMealPlan(day: "Monday", meals: [
                Meal(id: UUID(), name: "Avocado Toast", description: "With poached eggs", calories: 300, macros: MacroGoal(protein: 15, carbs: 30, fat: 15, calories: 300), mealType: .breakfast, ingredients: ["2 slices of bread", "1 avocado", "2 eggs"], steps: ["Toast the bread.", "Mash avocado and spread on toast.", "Poach the eggs and place on the toast."]),
                Meal(id: UUID(), name: "Grilled Chicken Salad", description: "With balsamic vinaigrette", calories: 450, macros: MacroGoal(protein: 35, carbs: 40, fat: 20, calories: 450), mealType: .lunch, ingredients: ["Chicken breast", "Mixed greens", "Balsamic vinaigrette"], steps: ["Grill the chicken.", "Mix the greens and add the chicken.", "Drizzle with balsamic vinaigrette."]),
                Meal(id: UUID(), name: "Steak with Quinoa", description: "Grilled steak with quinoa salad", calories: 600, macros: MacroGoal(protein: 45, carbs: 50, fat: 35, calories: 600), mealType: .dinner, ingredients: ["Steak", "Quinoa", "Steamed vegetables"], steps: ["Grill the steak to preferred doneness.", "Cook quinoa.", "Serve steak over quinoa and vegetables."])
            ], macros: MacroGoal(protein: 150, carbs: 200, fat: 50, calories: 2000), achievedMacros: MacroAchieved(protein: 100, carbs: 150, fat: 30, calories: 1350), isToday: today == "Monday"),

            DailyMealPlan(day: "Tuesday", meals: [
                Meal(id: UUID(), name: "Greek Yogurt with Berries", description: "Topped with honey and nuts", calories: 250, macros: MacroGoal(protein: 20, carbs: 25, fat: 5, calories: 250), mealType: .breakfast, ingredients: ["Greek yogurt", "Berries", "Honey", "Nuts"], steps: ["Mix yogurt and berries.", "Add honey and nuts on top."]),
                Meal(id: UUID(), name: "Turkey Club Sandwich", description: "With avocado and bacon", calories: 500, macros: MacroGoal(protein: 40, carbs: 45, fat: 25, calories: 500), mealType: .lunch, ingredients: ["Turkey breast", "Bread", "Avocado", "Bacon", "Lettuce", "Tomato"], steps: ["Grill the turkey.", "Assemble the sandwich with avocado, bacon, lettuce, and tomato."]),
                Meal(id: UUID(), name: "Beef Stir-Fry", description: "With mixed vegetables", calories: 550, macros: MacroGoal(protein: 50, carbs: 40, fat: 30, calories: 550), mealType: .dinner, ingredients: ["Beef", "Mixed vegetables", "Stir-fry sauce"], steps: ["Stir-fry the beef and vegetables.", "Add stir-fry sauce and serve."])
            ], macros: MacroGoal(protein: 155, carbs: 210, fat: 47, calories: 2050), achievedMacros: MacroAchieved(protein: 120, carbs: 180, fat: 40, calories: 1900), isToday: today == "Tuesday"),

            DailyMealPlan(day: "Wednesday", meals: [
                Meal(id: UUID(), name: "Protein Pancakes", description: "With maple syrup", calories: 350, macros: MacroGoal(protein: 25, carbs: 45, fat: 10, calories: 350), mealType: .breakfast, ingredients: ["Protein powder", "Pancake mix", "Eggs", "Maple syrup"], steps: ["Mix protein powder and pancake mix.", "Add eggs and cook on a pan.", "Serve with maple syrup."]),
                Meal(id: UUID(), name: "Quinoa Salad", description: "With chickpeas and feta", calories: 400, macros: MacroGoal(protein: 15, carbs: 50, fat: 20, calories: 400), mealType: .lunch, ingredients: ["Quinoa", "Chickpeas", "Feta cheese", "Mixed greens"], steps: ["Cook quinoa.", "Mix with chickpeas, feta cheese, and mixed greens."]),
                Meal(id: UUID(), name: "Salmon with Asparagus", description: "Grilled salmon with a side of asparagus", calories: 600, macros: MacroGoal(protein: 50, carbs: 25, fat: 40, calories: 600), mealType: .dinner, ingredients: ["Salmon", "Asparagus"], steps: ["Grill the salmon.", "Steam the asparagus."])
            ], macros: MacroGoal(protein: 160, carbs: 200, fat: 55, calories: 2100), achievedMacros: MacroAchieved(protein: 130, carbs: 190, fat: 45, calories: 1980), isToday: today == "Wednesday"),

            DailyMealPlan(day: "Thursday", meals: [
                Meal(id: UUID(), name: "Smoothie Bowl", description: "With banana and granola", calories: 330, macros: MacroGoal(protein: 15, carbs: 55, fat: 8, calories: 330), mealType: .breakfast, ingredients: ["Banana", "Yogurt", "Granola"], steps: ["Blend banana and yogurt.", "Top with granola."]),
                Meal(id: UUID(), name: "Chicken Wrap", description: "With hummus and vegetables", calories: 480, macros: MacroGoal(protein: 35, carbs: 50, fat: 18, calories: 480), mealType: .lunch, ingredients: ["Chicken breast", "Tortilla", "Hummus", "Mixed vegetables"], steps: ["Grill the chicken.", "Assemble the wrap with hummus and vegetables."]),
                Meal(id: UUID(), name: "Spaghetti Bolognese", description: "Classic spaghetti with meat sauce", calories: 700, macros: MacroGoal(protein: 45, carbs: 80, fat: 25, calories: 700), mealType: .dinner, ingredients: ["Spaghetti", "Ground beef", "Tomato sauce"], steps: ["Cook spaghetti.", "Cook ground beef and tomato sauce.", "Combine and serve."])
            ], macros: MacroGoal(protein: 150, carbs: 220, fat: 52, calories: 2150), achievedMacros: MacroAchieved(protein: 125, carbs: 200, fat: 40, calories: 1910), isToday: today == "Thursday"),

            DailyMealPlan(day: "Friday", meals: [
                Meal(id: UUID(), name: "Oatmeal", description: "With almond milk and honey", calories: 300, macros: MacroGoal(protein: 10, carbs: 50, fat: 5, calories: 300), mealType: .breakfast, ingredients: ["Oatmeal", "Almond milk", "Honey"], steps: ["Cook oatmeal.", "Add almond milk and honey."]),
                Meal(id: UUID(), name: "Tuna Salad", description: "With lettuce and olive oil", calories: 360, macros: MacroGoal(protein: 30, carbs: 10, fat: 25, calories: 360), mealType: .lunch, ingredients: ["Tuna", "Lettuce", "Olive oil"], steps: ["Mix tuna with lettuce and olive oil."]),
                Meal(id: UUID(), name: "Chicken Alfredo", description: "Pasta with creamy sauce", calories: 650, macros: MacroGoal(protein: 40, carbs: 70, fat: 30, calories: 650), mealType: .dinner, ingredients: ["Pasta", "Chicken breast", "Alfredo sauce"], steps: ["Cook pasta.", "Grill chicken and add to pasta.", "Add Alfredo sauce and serve."])
            ], macros: MacroGoal(protein: 140, carbs: 200, fat: 50, calories: 2000), achievedMacros: MacroAchieved(protein: 110, carbs: 180, fat: 35, calories: 2015), isToday: today == "Friday"),

            DailyMealPlan(day: "Saturday", meals: [
                Meal(id: UUID(), name: "Scrambled Eggs", description: "With spinach and cheese", calories: 250, macros: MacroGoal(protein: 18, carbs: 5, fat: 20, calories: 250), mealType: .breakfast, ingredients: ["Eggs", "Spinach", "Cheese"], steps: ["Scramble eggs.", "Add spinach and cheese."]),
                Meal(id: UUID(), name: "Pasta Salad", description: "With pesto and vegetables", calories: 500, macros: MacroGoal(protein: 15, carbs: 70, fat: 18, calories: 500), mealType: .lunch, ingredients: ["Pasta", "Pesto", "Mixed vegetables"], steps: ["Cook pasta.", "Mix with pesto and vegetables."]),
                Meal(id: UUID(), name: "Roast Chicken", description: "With roasted potatoes", calories: 750, macros: MacroGoal(protein: 60, carbs: 60, fat: 40, calories: 750), mealType: .dinner, ingredients: ["Chicken", "Potatoes"], steps: ["Roast chicken.", "Roast potatoes."])
            ], macros: MacroGoal(protein: 145, carbs: 210, fat: 51, calories: 2050), achievedMacros: MacroAchieved(protein: 120, carbs: 190, fat: 38, calories: 2005), isToday: today == "Saturday"),

            DailyMealPlan(day: "Sunday", meals: [
                Meal(id: UUID(), name: "French Toast", description: "With syrup and berries", calories: 400, macros: MacroGoal(protein: 12, carbs: 60, fat: 12, calories: 400), mealType: .breakfast, ingredients: ["Bread", "Eggs", "Syrup", "Berries"], steps: ["Dip bread in egg mixture.", "Cook on a pan.", "Serve with syrup and berries."]),
                Meal(id: UUID(), name: "Caesar Salad", description: "With grilled chicken", calories: 400, macros: MacroGoal(protein: 35, carbs: 20, fat: 25, calories: 400), mealType: .lunch, ingredients: ["Chicken breast", "Romaine lettuce", "Croutons", "Caesar dressing"], steps: ["Grill chicken.", "Assemble salad with lettuce, croutons, and Caesar dressing."]),
                Meal(id: UUID(), name: "Beef Tacos", description: "With salsa and guacamole", calories: 650, macros: MacroGoal(protein: 45, carbs: 50, fat: 35, calories: 650), mealType: .dinner, ingredients: ["Beef", "Tortillas", "Salsa", "Guacamole"], steps: ["Cook beef.", "Assemble tacos with salsa and guacamole."])
            ], macros: MacroGoal(protein: 155, carbs: 215, fat: 53, calories: 2100), achievedMacros: MacroAchieved(protein: 125, carbs: 195, fat: 42, calories: 1960), isToday: today == "Sunday")
        ])
    }
}
