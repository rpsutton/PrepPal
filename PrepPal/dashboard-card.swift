import SwiftUI

// MARK: - Nutrition Dashboard Card
struct NutritionDashboardCard: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    let dailyPlan: DailyMealPlan
    @Binding var showFullMealPlan: Bool
    @Binding var selectedMeal: Meal?
    @Binding var showMealDetail: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header with day and actions
            dashboardHeader
            
            // Content
            VStack(spacing: 12) {
                // Macro progress summary
                macroProgressSummary
                
                // Collapsible meal list
                mealsSection
                
                // View full plan button
                viewFullPlanButton
            }
            .padding()
        }
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Header
    private var dashboardHeader: some View {
        HStack {
            // Day with today indicator
            HStack(spacing: 8) {
                if dailyPlan.isToday {
                    Circle()
                        .fill(PrepPalTheme.Colors.primary)
                        .frame(width: 8, height: 8)
                }
                
                Text(dailyPlan.day)
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                    .fontWeight(dailyPlan.isToday ? .bold : .regular)
            }
            
            Spacer()
            
            // Calorie display
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(PrepPalTheme.Colors.secondary)
                    .font(.system(size: 14))
                
                Text("\(Int(dailyPlan.achievedMacros.calories))/\(dailyPlan.macros.calories)")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(PrepPalTheme.Colors.secondary.opacity(0.1))
            .cornerRadius(PrepPalTheme.Layout.pillCornerRadius)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(dailyPlan.isToday ? PrepPalTheme.Colors.primary.opacity(0.05) : PrepPalTheme.Colors.cardBackground)
    }
    
    // MARK: - Macro Progress Summary
    private var macroProgressSummary: some View {
        HStack(spacing: 8) {
            macroProgressPill(
                value: Int(dailyPlan.achievedMacros.protein),
                target: Int(dailyPlan.macros.protein),
                label: "P",
                color: PrepPalTheme.Colors.primary
            )
            
            macroProgressPill(
                value: Int(dailyPlan.achievedMacros.carbs),
                target: Int(dailyPlan.macros.carbs),
                label: "C",
                color: PrepPalTheme.Colors.accentRed
            )
            
            macroProgressPill(
                value: Int(dailyPlan.achievedMacros.fat),
                target: Int(dailyPlan.macros.fat),
                label: "F",
                color: PrepPalTheme.Colors.warning
            )
        }
    }
    
    // MARK: - Macro Progress Pill
    private func macroProgressPill(value: Int, target: Int, label: String, color: Color) -> some View {
        let progress = min(1.0, Double(value) / Double(target))
        
        return HStack(spacing: 4) {
            // Progress circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: 28, height: 28)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, lineWidth: 3)
                    .frame(width: 28, height: 28)
                    .rotationEffect(.degrees(-90))
                
                Text(label)
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(color)
            }
            
            // Values
            Text("\(value)/\(target)g")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(PrepPalTheme.Layout.pillCornerRadius)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Meals Section
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Meals")
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            ForEach(dailyPlan.meals) { meal in
                Button(action: {
                    selectedMeal = meal
                    showMealDetail = true
                }) {
                    HStack(spacing: 12) {
                        // Meal type icon
                        ZStack {
                            Circle()
                                .fill(colorForMealType(meal.mealType).opacity(0.2))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: iconForMealType(meal.mealType))
                                .foregroundColor(colorForMealType(meal.mealType))
                                .font(.system(size: 14))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.name)
                                .font(PrepPalTheme.Typography.bodyRegular)
                                .foregroundColor(PrepPalTheme.Colors.gray600)
                                .lineLimit(1)
                            
                            Text("\(meal.calories) cal • \(Int(meal.macros.protein))g protein")
                                .font(PrepPalTheme.Typography.caption)
                                .foregroundColor(PrepPalTheme.Colors.gray400)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(PrepPalTheme.Colors.gray400)
                            .font(.system(size: 14))
                    }
                    .padding(10)
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
        }
    }
    
    // MARK: - View Full Plan Button
    private var viewFullPlanButton: some View {
        Button(action: {
            showFullMealPlan = true
        }) {
            HStack {
                Text("View Full Week Plan")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.primary)
                
                Image(systemName: "calendar")
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(PrepPalTheme.Colors.primary.opacity(0.1))
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        }
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
    NutritionDashboardCard(
        dailyPlan: WeeklyMealPlan.createSampleData().dailyPlans.first!,
        showFullMealPlan: .constant(false),
        selectedMeal: .constant(nil),
        showMealDetail: .constant(false)
    )
    .environmentObject(UserProfileManager())
    .padding()
    .background(PrepPalTheme.Colors.background)
}
