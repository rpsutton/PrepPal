import SwiftUI

// MARK: - Daily Macro Progress Card for Chat
struct DailyMacroProgressCard: View {
    let dailyPlan: DailyMealPlan
    let nutritionGoals: NutritionGoals?
    
    private var calorieProgress: Double {
        guard let goals = nutritionGoals else { return 0 }
        return min(1.0, Double(dailyPlan.achievedMacros.calories) / Double(goals.calorieGoal))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            cardHeader
            
            // Main content
            VStack(spacing: 16) {
                // Overall progress ring
                overallProgressView
                
                // Detailed macro progress
                detailedMacroProgress
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
            
            // Meal breakdown
            mealBreakdownSection
        }
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Card Header
    private var cardHeader: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Today's Nutrition")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text(dailyPlan.day)
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
            
            if let goals = nutritionGoals {
                HStack {
                    Text("\(Int(dailyPlan.achievedMacros.calories)) / \(goals.calorieGoal) calories")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                    
                    Spacer()
                    
                    statusBadge
                }
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.primary.opacity(0.05))
        .cornerRadius(PrepPalTheme.Layout.cornerRadius, corners: [.topLeft, .topRight])
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 4) {
            if calorieProgress >= 0.9 && calorieProgress <= 1.1 {
                Circle()
                    .fill(PrepPalTheme.Colors.success)
                    .frame(width: 8, height: 8)
                
                Text("On Track")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(PrepPalTheme.Colors.success)
            } else if calorieProgress > 1.1 {
                Circle()
                    .fill(PrepPalTheme.Colors.warning)
                    .frame(width: 8, height: 8)
                
                Text("Over Goal")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(PrepPalTheme.Colors.warning)
            } else {
                Circle()
                    .fill(PrepPalTheme.Colors.accentRed)
                    .frame(width: 8, height: 8)
                
                Text("Under Goal")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(PrepPalTheme.Colors.accentRed)
            }
        }
    }
    
    // MARK: - Overall Progress View
    private var overallProgressView: some View {
        HStack(spacing: 20) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(PrepPalTheme.Colors.gray100, lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: calorieProgress)
                    .stroke(
                        calorieProgress >= 0.9 && calorieProgress <= 1.1 ?
                            PrepPalTheme.Colors.success :
                            (calorieProgress > 1.1 ? PrepPalTheme.Colors.warning : PrepPalTheme.Colors.accentRed),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut, value: calorieProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(calorieProgress * 100))%")
                        .font(PrepPalTheme.Typography.headerLarge)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    Text("of daily goal")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                }
            }
            
            // Summary text
            VStack(alignment: .leading, spacing: 12) {
                // Calories remaining
                if let goals = nutritionGoals {
                    let remaining = max(0, goals.calorieGoal - Int(dailyPlan.achievedMacros.calories))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(remaining > 0 ? "\(remaining) cal remaining" : "Goal reached!")
                            .font(PrepPalTheme.Typography.bodyRegular.bold())
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                        
                        Text(remaining > 0 ? "Keep going!" : "Great job today!")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.gray400)
                    }
                }
                
                // Protein highlight
                if let goals = nutritionGoals {
                    let proteinProgress = dailyPlan.achievedMacros.protein / goals.macros.protein
                    
                    HStack(spacing: 8) {
                        Image(systemName: proteinProgress >= 0.9 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(proteinProgress >= 0.9 ? 
                                           PrepPalTheme.Colors.success : 
                                           PrepPalTheme.Colors.gray400)
                        
                        Text("\(Int(dailyPlan.achievedMacros.protein))g protein")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                    }
                }
            }
        }
    }
    
    // MARK: - Detailed Macro Progress
    private var detailedMacroProgress: some View {
        VStack(spacing: 12) {
            if let goals = nutritionGoals {
                // Protein progress
                macroProgressBar(
                    label: "Protein",
                    value: Int(dailyPlan.achievedMacros.protein),
                    target: Int(goals.macros.protein),
                    color: PrepPalTheme.Colors.primary
                )
                
                // Carbs progress
                macroProgressBar(
                    label: "Carbs",
                    value: Int(dailyPlan.achievedMacros.carbs),
                    target: Int(goals.macros.carbs),
                    color: PrepPalTheme.Colors.accentRed
                )
                
                // Fat progress
                macroProgressBar(
                    label: "Fat",
                    value: Int(dailyPlan.achievedMacros.fat),
                    target: Int(goals.macros.fat),
                    color: PrepPalTheme.Colors.warning
                )
            } else {
                Text("Set nutrition goals to see detailed progress")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // MARK: - Macro Progress Bar
    private func macroProgressBar(label: String, value: Int, target: Int, color: Color) -> some View {
        let progress = min(1.0, Double(value) / Double(target))
        
        return VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text("\(value) / \(target)g")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: PrepPalTheme.Layout.progressBarHeight/2)
                        .fill(color.opacity(0.2))
                        .frame(height: PrepPalTheme.Layout.progressBarHeight)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: PrepPalTheme.Layout.progressBarHeight/2)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: PrepPalTheme.Layout.progressBarHeight)
                }
            }
            .frame(height: PrepPalTheme.Layout.progressBarHeight)
        }
    }
    
    // MARK: - Meal Breakdown Section
    private var mealBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Meals Today")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                if dailyPlan.meals.count > 0 {
                    Text("\(dailyPlan.meals.count) meals")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // Divider
            Rectangle()
                .fill(PrepPalTheme.Colors.gray100)
                .frame(height: 1)
            
            // Meal list
            VStack(spacing: 0) {
                ForEach(Array(dailyPlan.meals.enumerated()), id: \.element.id) { index, meal in
                    mealSummaryRow(meal: meal)
                    
                    if index < dailyPlan.meals.count - 1 {
                        Rectangle()
                            .fill(PrepPalTheme.Colors.gray100)
                            .frame(height: 1)
                            .padding(.leading, 60)
                    }
                }
            }
        }
    }
    
    // MARK: - Meal Summary Row
    private func mealSummaryRow(meal: Meal) -> some View {
        HStack(spacing: 12) {
            // Meal type icon
            ZStack {
                Circle()
                    .fill(colorForMealType(meal.mealType).opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: iconForMealType(meal.mealType))
                    .foregroundColor(colorForMealType(meal.mealType))
                    .font(.system(size: 16))
            }
            
            // Meal info
            VStack(alignment: .leading, spacing: 2) {
                Text(meal.name)
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Text(meal.mealType.rawValue)
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
            }
            
            Spacer()
            
            // Macro summary
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(meal.calories) cal")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Text("\(Int(meal.macros.protein))g protein")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Functions
    private func colorForMealType(_ type: Meal.MealType) -> Color {
        switch type {
        case .breakfast: return PrepPalTheme.Colors.primary
        case .lunch: return PrepPalTheme.Colors.secondary
        case .dinner: return PrepPalTheme.Colors.accentNavy
        case .snack: return PrepPalTheme.Colors.accentRed
        }
    }
    
    private func iconForMealType(_ type: Meal.MealType) -> String {
        switch type {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "carrot.fill"
        }
    }
}

// MARK: - Preview
#Preview {
    let samplePlan = WeeklyMealPlan.createSampleData().dailyPlans.first!
    let userManager = UserProfileManager()
    userManager.userProfile.generateNutritionGoals(
        goalType: .maintenance,
        dietaryPattern: .balanced
    )
    
    return DailyMacroProgressCard(
        dailyPlan: samplePlan,
        nutritionGoals: userManager.userProfile.nutritionGoals
    )
    .padding()
    .background(PrepPalTheme.Colors.background)
}