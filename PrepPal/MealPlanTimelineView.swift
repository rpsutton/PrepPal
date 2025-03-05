import SwiftUI

struct MealPlanTimelineView: View {
    let weeklyPlan: WeeklyMealPlan
    @Binding var selectedMeal: Meal?
    @Binding var showDetail: Bool
    @State private var showModifySheet = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(weeklyPlan.dailyPlans) { dailyPlan in
                        DaySection(
                            dailyPlan: dailyPlan,
                            selectedMeal: $selectedMeal,
                            showDetail: $showDetail
                        )
                    }
                }
                .padding()
            }
            .background(PrepPalTheme.Colors.background)
            
            // Floating edit button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    editPlanButton
                }
                .padding()
            }
        }
        .sheet(isPresented: $showModifySheet) {
            modifyMealPlanView
        }
    }
    
    // MARK: - Floating Edit Button
    private var editPlanButton: some View {
        Button(action: {
            showModifySheet = true
        }) {
            ZStack {
                Circle()
                    .fill(PrepPalTheme.Colors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: PrepPalTheme.Colors.shadow.opacity(0.3), radius: 4, y: 2)
                
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Modify Meal Plan View (Conversational)
    private var modifyMealPlanView: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: {
                        showModifySheet = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                    }
                    Spacer()
                }
                
                Text("Modify Meal Plan")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
            
            // Modification Options
            ScrollView {
                VStack(spacing: 16) {
                    Text("How would you like to modify your meal plan?")
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .padding()
                        .background(PrepPalTheme.Colors.assistantMessage)
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Modification options
                    modificationOptionButton(
                        icon: "chart.bar.fill",
                        title: "Adjust Macros",
                        description: "Change protein, carbs, or fat targets"
                    )
                    
                    modificationOptionButton(
                        icon: "arrow.triangle.swap",
                        title: "Swap Meals",
                        description: "Replace specific meals in your plan"
                    )
                    
                    modificationOptionButton(
                        icon: "flame.fill",
                        title: "Change Flavors",
                        description: "Adjust cuisine types or flavors"
                    )
                    
                    modificationOptionButton(
                        icon: "calendar.badge.plus",
                        title: "Add or Remove Days",
                        description: "Modify which days to include"
                    )
                    
                    modificationOptionButton(
                        icon: "list.bullet",
                        title: "Generate Shopping List",
                        description: "Create a shopping list from your plan"
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Input area for conversational approach
            HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                TextField("Tell me how to modify your plan...", text: .constant(""))
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                
                Button(action: {
                    // Send message action
                    showModifySheet = false
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(PrepPalTheme.Colors.primary)
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: -1)
        }
        .background(PrepPalTheme.Colors.background)
    }
    
    private func modificationOptionButton(icon: String, title: String, description: String) -> some View {
        Button(action: {
            showModifySheet = false
            // In a real app, this would trigger the specific modification flow
        }) {
            HStack {
                ZStack {
                    Circle()
                        .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    Text(description)
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(PrepPalTheme.Colors.gray400)
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
        }
    }
}

struct DaySection: View {
    let dailyPlan: DailyMealPlan
    @Binding var selectedMeal: Meal?
    @Binding var showDetail: Bool
    
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
                        .onTapGesture {
                            selectedMeal = meal
                            showDetail = true
                        }
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
        weeklyPlan: WeeklyMealPlan.createSampleData(),
        selectedMeal: .constant(nil),
        showDetail: .constant(false)
    )
}
