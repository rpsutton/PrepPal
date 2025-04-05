import SwiftUI

struct MealPlanTimelineView: View {
    let weeklyPlan: WeeklyMealPlan
    @State private var showModificationSheet: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(weeklyPlan.dailyPlans) { dailyPlan in
                        DaySection(dailyPlan: dailyPlan)
                    }
                }
                .padding()
            }
            .background(PrepPalTheme.Colors.cardBackground)
            
            // Floating modification button
            VStack {
                Spacer()
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
            MealPlanModificationView(plan: weeklyPlan, isPresented: $showModificationSheet)
        }
    }
}

struct DaySection: View {
    let dailyPlan: DailyMealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day header with date and macro summary
            VStack(spacing: 8) {
                HStack {
                    HStack(spacing: 12) {
                        // Today indicator
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
                    
                    Text("\(Int(dailyPlan.macros.calories)) cal")
                        .font(PrepPalTheme.Typography.caption.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                }
                
                // Detailed macro breakdown with actual values
                HStack(spacing: 20) {
                    macroDisplay(
                        label: "Protein",
                        value: "\(Int(dailyPlan.macros.protein))g",
                        progress: dailyPlan.achievedMacros.protein / dailyPlan.macros.protein,
                        color: PrepPalTheme.Colors.primary
                    )
                    
                    macroDisplay(
                        label: "Carbs",
                        value: "\(Int(dailyPlan.macros.carbs))g",
                        progress: dailyPlan.achievedMacros.carbs / dailyPlan.macros.carbs,
                        color: PrepPalTheme.Colors.accentRed
                    )
                    
                    macroDisplay(
                        label: "Fat",
                        value: "\(Int(dailyPlan.macros.fat))g",
                        progress: dailyPlan.achievedMacros.fat / dailyPlan.macros.fat,
                        color: PrepPalTheme.Colors.warning
                    )
                }
            }
            .padding(.horizontal, 4)
            
            // Meals for the day
            VStack(spacing: 12) {
                ForEach(dailyPlan.meals) { meal in
                    TimelineMealCard(meal: meal)
                }
            }
        }
        .padding(.bottom, 8)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(PrepPalTheme.Colors.gray100)
                .offset(y: 12),
            alignment: .bottom
        )
    }
    
    // Macro display with label, value and mini progress bar
    private func macroDisplay(label: String, value: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(label)
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Text(value)
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
            }
            
            // Mini progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(PrepPalTheme.Colors.gray100)
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * min(1.0, progress), height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TimelineMealCard: View {
    let meal: Meal
    
    var body: some View {
        NavigationLink(destination: RecipeCardView(meal: meal, mode: .preview)) {
            HStack(spacing: 16) {
                // Meal type icon
                ZStack {
                    Circle()
                        .fill(colorForMealType(meal.mealType).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconForMealType(meal.mealType))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(colorForMealType(meal.mealType))
                }
                
                // Meal details
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(meal.name)
                            .font(PrepPalTheme.Typography.bodyRegular)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("\(meal.calories) cal")
                            .font(PrepPalTheme.Typography.caption.bold())
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                    }
                    
                    Text(meal.description)
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .lineLimit(1)
                    
                    // Macro values
                    HStack(spacing: 12) {
                        macroIndicator(value: Int(meal.macros.protein), label: "P", color: PrepPalTheme.Colors.primary)
                        macroIndicator(value: Int(meal.macros.carbs), label: "C", color: PrepPalTheme.Colors.accentRed)
                        macroIndicator(value: Int(meal.macros.fat), label: "F", color: PrepPalTheme.Colors.warning)
                    }
                }
                
                // Chevron indicator
                Image(systemName: "chevron.right")
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .font(.system(size: 14))
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .navigationTitle("Meal Plan")
    }
    
    private func macroIndicator(value: Int, label: String, color: Color) -> some View {
        HStack(spacing: 2) {
            Text("\(value)g")
                .font(PrepPalTheme.Typography.caption.bold())
                .foregroundColor(color)
            
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(color.opacity(0.7))
        }
    }
    
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

#Preview {
    MealPlanTimelineView(
        weeklyPlan: WeeklyMealPlan.createSampleData()
    )
}
