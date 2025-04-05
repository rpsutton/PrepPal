import SwiftUI

struct RecipeCardView: View {
    let meal: Meal
    let mode: RecipeViewMode
    var onStartCooking: () -> Void = {}
    
    // By default, show all sections
    @State private var expandedSection: RecipeSection? = nil
    @State private var completedSteps: Set<Int> = []
    @State private var checkedIngredients: Set<Int> = []
    @State private var activeTimers: [Int: Timer] = [:]
    @State private var remainingTimes: [Int: Int] = [:]
    @State private var stepTimers: [Int: Int] = [:] // Stores the intended duration for each step
    @State private var showModificationSheet: Bool = false
    
    enum RecipeViewMode {
        case preview
        case cooking
    }
    
    var body: some View {
        ZStack {
            // Background color for cooking mode
            if mode == .cooking {
                PrepPalTheme.Colors.background
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: PrepPalTheme.Layout.elementSpacing) {
                    // Recipe Header with Image
                    RecipeHeaderView(meal: meal, totalTime: RecipeTimerUtils.calculateTotalTime(steps: meal.steps))
                    
                    // Recipe Content
                    VStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                        // Description & Macros
                        RecipeDescriptionView(meal: meal, expandedSection: expandedSection)
                        
                        // Ingredients Section
                        RecipeIngredientsView(
                            meal: meal, 
                            expandedSection: expandedSection, 
                            checkedIngredients: $checkedIngredients
                        )
                        
                        // Instructions Section
                        RecipeInstructionsView(
                            meal: meal, 
                            expandedSection: expandedSection, 
                            completedSteps: $completedSteps, 
                            activeTimers: $activeTimers, 
                            remainingTimes: $remainingTimes, 
                            stepTimers: $stepTimers
                        )
                    }
                    .padding(PrepPalTheme.Layout.basePadding)
                }
            }
            .background(PrepPalTheme.Colors.cardBackground)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
            
            // Floating overlay elements
            VStack {
                Spacer()
                
                // Floating timer that stays visible
                if !activeTimers.isEmpty,
                   let index = activeTimers.keys.first,
                   let remaining = remainingTimes[index] {
                    FloatingTimerView(
                        stepIndex: index, 
                        remaining: remaining, 
                        stopTimer: stopTimer
                    )
                    .padding(.bottom, 70)
                }
                
                // Floating modification button
                HStack {
                    Spacer()
                    RecipeModificationButton(action: {
                        showModificationSheet = true
                    })
                }
                .padding(PrepPalTheme.Layout.basePadding)
            }
        }
        .sheet(isPresented: $showModificationSheet) {
            RecipeModificationView(meal: meal, isPresented: $showModificationSheet)
        }
    }
    
    // MARK: - Helper Functions
    
    private func stopTimer(for stepIndex: Int) {
        activeTimers[stepIndex]?.invalidate()
        activeTimers[stepIndex] = nil
        remainingTimes[stepIndex] = 0
    }
    
    func toggleSection(_ section: RecipeSection) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if expandedSection == section {
                expandedSection = nil
            } else {
                expandedSection = section
            }
        }
    }
}

#Preview {
    RecipeCardView(meal: Meal(
        id: UUID(),
        name: "Quick Chicken Meal Prep",
        description: "Seasoned chicken breast with roasted vegetables and brown rice. High protein, balanced carbs, and healthy fats in one simple prep.",
        calories: 425,
        macros: MacroGoal(protein: 38, carbs: 32, fat: 14, calories: 425),
        mealType: .dinner,
        ingredients: [
            "1.5 lbs chicken breast",
            "2 cups broccoli",
            "2 bell peppers",
            "1 cup uncooked brown rice",
            "2 tbsp olive oil",
            "1 tsp garlic powder",
            "1 tsp paprika",
            "Salt to taste",
            "Black pepper to taste"
        ],
        steps: [
            "Preheat oven to 425°F and start cooking brown rice according to package instructions.",
            "Cut chicken into even pieces and season with garlic powder, paprika, salt, and pepper.",
            "Chop vegetables into bite-sized pieces and toss with olive oil, salt, and pepper.",
            "Place chicken on one half of a baking sheet and vegetables on the other half.",
            "Bake for 20-25 minutes until chicken reaches 165°F and vegetables are tender.",
            "Divide rice between meal prep containers, top with chicken and vegetables."
        ]
    ), mode: .preview)
}
