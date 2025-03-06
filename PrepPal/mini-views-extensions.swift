import SwiftUI

// MARK: - Mini Views for Chat Interactions
struct MacroMiniSummary: View {
    let dailyPlan: DailyMealPlan
    
    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                .frame(width: 4)
                .padding(.vertical, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Today's Nutrition")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                HStack(spacing: 16) {
                    statView(value: "\(Int(dailyPlan.achievedMacros.calories))", unit: "cal", color: PrepPalTheme.Colors.secondary)
                    statView(value: "\(Int(dailyPlan.achievedMacros.protein))g", unit: "protein", color: PrepPalTheme.Colors.primary)
                    statView(value: "\(Int(dailyPlan.achievedMacros.carbs))g", unit: "carbs", color: PrepPalTheme.Colors.accentRed)
                    statView(value: "\(Int(dailyPlan.achievedMacros.fat))g", unit: "fat", color: PrepPalTheme.Colors.warning)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .font(.system(size: 14))
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow, 
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0, 
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    private func statView(value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(color)
            
            Text(unit)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray400)
        }
    }
}

// MARK: - Persistent Mini Macro Bar
struct PersistentMacroBar: View {
    let dailyPlan: DailyMealPlan
    let nutritionGoals: NutritionGoals?
    let onTap: () -> Void
    
    private var calorieProgress: Double {
        guard let goals = nutritionGoals else { return 0 }
        return min(1.0, Double(dailyPlan.achievedMacros.calories) / Double(goals.calorieGoal))
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Progress circles
                if let goals = nutritionGoals {
                    // Calorie progress
                    miniProgressCircle(
                        value: Double(dailyPlan.achievedMacros.calories),
                        total: Double(goals.calorieGoal),
                        color: PrepPalTheme.Colors.secondary
                    )
                    
                    // Protein progress
                    miniProgressCircle(
                        value: dailyPlan.achievedMacros.protein,
                        total: goals.macros.protein,
                        color: PrepPalTheme.Colors.primary
                    )
                } else {
                    // Placeholder indicator for no goals
                    Circle()
                        .stroke(PrepPalTheme.Colors.gray400, lineWidth: 2)
                        .frame(width: 24, height: 24)
                }
                
                // Text summary
                if let goals = nutritionGoals {
                    Text("\(Int(dailyPlan.achievedMacros.calories))/\(goals.calorieGoal) cal")
                        .font(PrepPalTheme.Typography.caption.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                } else {
                    Text("Set nutrition goals")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(PrepPalTheme.Colors.cardBackground)
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: -1)
        }
    }
    
    // Mini progress circle for the persistent bar
    private func miniProgressCircle(value: Double, total: Double, color: Color) -> some View {
        let progress = min(1.0, value / total)
        
        return ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 2)
                .frame(width: 24, height: 24)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, lineWidth: 2)
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Message Extension for Meal Plan Mini Preview
struct MealPlanMiniPreview: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
                
                // Meal details
                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text("\(meal.calories) cal")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.secondary)
                        
                        Text("•")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.gray400)
                        
                        Text("\(Int(meal.macros.protein))g protein")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.primary)
                    }
                }
                
                Spacer()
                
                // View details chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .font(.system(size: 14))
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            .shadow(color: PrepPalTheme.Colors.shadow, 
                    radius: PrepPalTheme.Layout.shadowRadius/2,
                    x: 0, 
                    y: PrepPalTheme.Layout.shadowY/2)
        }
    }
    
    // Helper functions
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
