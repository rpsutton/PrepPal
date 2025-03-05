import SwiftUI

// MARK: - Nutrition Goal Card
struct NutritionGoalCard: View {
    let nutritionGoals: NutritionGoals
    let onAdjust: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            goalCardHeader
            
            // Card Content
            macroBreakdown
        }
        .background(PrepPalTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Card Header
    private var goalCardHeader: some View {
        VStack(spacing: 0) {
            HStack {
                // Icon and Title
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(PrepPalTheme.Colors.primary)
                            .font(.system(size: 18))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(nutritionGoals.goalType.rawValue) Plan")
                            .font(PrepPalTheme.Typography.headerMedium)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                        
                        Text("\(nutritionGoals.dietaryPattern.rawValue) • \(nutritionGoals.calorieGoal) cal/day")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.gray400)
                    }
                }
                
                Spacer()
                
                // Edit button
                Button(action: onAdjust) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .font(.system(size: 18))
                        .padding(10)
                        .background(PrepPalTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
            .padding(PrepPalTheme.Layout.basePadding)
            
            Divider()
                .background(PrepPalTheme.Colors.border)
        }
    }
    
    // MARK: - Macro Breakdown
    private var macroBreakdown: some View {
        VStack(spacing: 16) {
            // Calories target
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Calories")
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    Text("Your daily energy target")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                }
                
                Spacer()
                
                Text("\(nutritionGoals.calorieGoal)")
                    .font(PrepPalTheme.Typography.headerLarge)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Text("cal")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .padding(.leading, 2)
            }
            
            // Macro distribution visualization
            macroDistributionChart
            
            // Individual macro targets
            VStack(spacing: 12) {
                macroRow(
                    label: "Protein",
                    value: Int(nutritionGoals.macros.protein),
                    unit: "g",
                    color: PrepPalTheme.Colors.primary,
                    percentage: Int((nutritionGoals.macros.protein * 4 / Double(nutritionGoals.calorieGoal)) * 100)
                )
                
                macroRow(
                    label: "Carbs",
                    value: Int(nutritionGoals.macros.carbs),
                    unit: "g",
                    color: PrepPalTheme.Colors.accentRed,
                    percentage: Int((nutritionGoals.macros.carbs * 4 / Double(nutritionGoals.calorieGoal)) * 100)
                )
                
                macroRow(
                    label: "Fat",
                    value: Int(nutritionGoals.macros.fat),
                    unit: "g",
                    color: PrepPalTheme.Colors.warning,
                    percentage: Int((nutritionGoals.macros.fat * 9 / Double(nutritionGoals.calorieGoal)) * 100)
                )
            }
        }
        .padding(PrepPalTheme.Layout.basePadding)
    }
    
    // Macro distribution pie chart
    private var macroDistributionChart: some View {
        HStack(spacing: 20) {
            // Simple pie chart visualization
            ZStack {
                Circle()
                    .trim(from: 0, to: calculatePieSlice(for: "protein"))
                    .stroke(PrepPalTheme.Colors.primary, lineWidth: 12)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: calculatePieSlice(for: "protein"),
                          to: calculatePieSlice(for: "protein") + calculatePieSlice(for: "carbs"))
                    .stroke(PrepPalTheme.Colors.accentRed, lineWidth: 12)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: calculatePieSlice(for: "protein") + calculatePieSlice(for: "carbs"),
                          to: 1)
                    .stroke(PrepPalTheme.Colors.warning, lineWidth: 12)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 80, height: 80)
            }
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                legendItem(color: PrepPalTheme.Colors.primary, label: "Protein")
                legendItem(color: PrepPalTheme.Colors.accentRed, label: "Carbs")
                legendItem(color: PrepPalTheme.Colors.warning, label: "Fat")
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
    }
    
    // Helper to create legend items
    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
        }
    }
    
    // Helper to create macro rows
    private func macroRow(label: String, value: Int, unit: String, color: Color, percentage: Int) -> some View {
        HStack {
            Text(label)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
            
            Text("\(value)\(unit)")
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(color)
            
            Text("(\(percentage)%)")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .padding(.leading, 2)
        }
        .padding(.vertical, 4)
    }
    
    // Calculate pie chart slice sizes
    private func calculatePieSlice(for macroType: String) -> Double {
        let proteinCals = nutritionGoals.macros.protein * 4
        let carbsCals = nutritionGoals.macros.carbs * 4
        let fatCals = nutritionGoals.macros.fat * 9
        let totalCals = Double(nutritionGoals.calorieGoal)
        
        switch macroType {
        case "protein":
            return proteinCals / totalCals
        case "carbs":
            return carbsCals / totalCals
        case "fat":
            return fatCals / totalCals
        default:
            return 0
        }
    }
}

// MARK: - Nutrition Progress View
struct NutritionProgressView: View {
    @ObservedObject var userProfileManager: UserProfileManager
    let dailyProgress: DailyMealPlan
    
    var body: some View {
        VStack(spacing: PrepPalTheme.Layout.elementSpacing) {
            // Progress overview
            HStack {
                Text("Today's Nutrition")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                // Progress indicator
                progressBadge
            }
            
            // Macro progress
            if let goals = userProfileManager.userProfile.nutritionGoals {
                VStack(spacing: 12) {
                    macroProgressBar(
                        title: "Calories",
                        current: Double(dailyProgress.achievedMacros.calories),
                        target: Double(goals.calorieGoal),
                        color: PrepPalTheme.Colors.secondary
                    )
                    
                    macroProgressBar(
                        title: "Protein",
                        current: dailyProgress.achievedMacros.protein,
                        target: goals.macros.protein,
                        color: PrepPalTheme.Colors.primary
                    )
                    
                    macroProgressBar(
                        title: "Carbs",
                        current: dailyProgress.achievedMacros.carbs,
                        target: goals.macros.carbs,
                        color: PrepPalTheme.Colors.accentRed
                    )
                    
                    macroProgressBar(
                        title: "Fat",
                        current: dailyProgress.achievedMacros.fat,
                        target: goals.macros.fat,
                        color: PrepPalTheme.Colors.warning
                    )
                }
            } else {
                Button(action: {
                    // Trigger goal setting conversation
                }) {
                    Text("Set nutrition goals to see daily progress")
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(PrepPalTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
        }
        .padding(PrepPalTheme.Layout.basePadding)
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // Progress badge
    private var progressBadge: some View {
        let progress = calculateOverallProgress()
        return ZStack {
            Circle()
                .stroke(PrepPalTheme.Colors.gray100, lineWidth: 3)
                .frame(width: 36, height: 36)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor(for: progress), lineWidth: 3)
                .frame(width: 36, height: 36)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(PrepPalTheme.Typography.caption.bold())
                .foregroundColor(progressColor(for: progress))
        }
    }
    
    // Macro progress bar
    private func macroProgressBar(title: String, current: Double, target: Double, color: Color) -> some View {
        let progress = min(1.0, current / target)
        
        return VStack(spacing: 4) {
            HStack {
                Text(title)
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text("\(Int(current)) / \(Int(target))")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(color)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: PrepPalTheme.Layout.progressBarHeight/2)
                        .fill(PrepPalTheme.Colors.gray100)
                        .frame(height: PrepPalTheme.Layout.progressBarHeight)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: PrepPalTheme.Layout.progressBarHeight/2)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: PrepPalTheme.Layout.progressBarHeight)
                        .opacity(0.8)
                }
            }
            .frame(height: PrepPalTheme.Layout.progressBarHeight)
        }
    }
    
    // Calculate weighted overall progress
    private func calculateOverallProgress() -> Double {
        guard let goals = userProfileManager.userProfile.nutritionGoals else {
            return 0
        }
        
        let calorieProgress = min(1.0, Double(dailyProgress.achievedMacros.calories) / Double(goals.calorieGoal))
        let proteinProgress = min(1.0, dailyProgress.achievedMacros.protein / goals.macros.protein)
        let carbsProgress = min(1.0, dailyProgress.achievedMacros.carbs / goals.macros.carbs)
        let fatProgress = min(1.0, dailyProgress.achievedMacros.fat / goals.macros.fat)
        
        // Weight protein progress higher (40%) than other macros
        return (proteinProgress * 0.4) + (carbsProgress * 0.2) + (fatProgress * 0.2) + (calorieProgress * 0.2)
    }
    
    // Color based on progress
    private func progressColor(for progress: Double) -> Color {
        if progress >= 0.9 { return PrepPalTheme.Colors.success }
        if progress >= 0.7 { return PrepPalTheme.Colors.primary }
        if progress >= 0.4 { return PrepPalTheme.Colors.warning }
        return PrepPalTheme.Colors.accentRed
    }
}

// MARK: - Nutrition Goal Message View
struct NutritionGoalMessageView: View {
    let nutritionGoals: NutritionGoals?
    let onSetGoals: () -> Void
    
    var body: some View {
        Button(action: onSetGoals) {
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: nutritionGoals == nil ? "plus" : "chart.bar.fill")
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .font(.system(size: 18))
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(nutritionGoals == nil ? "Set Nutrition Goals" : "View Nutrition Goals")
                        .font(PrepPalTheme.Typography.bodyRegular.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    Text(nutritionGoals == nil ?
                        "Tell me your goals for personalized plans" :
                        "\(nutritionGoals!.goalType.rawValue) • \(Int(nutritionGoals!.macros.protein))g protein • \(nutritionGoals!.calorieGoal) cal")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .lineLimit(1)
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
    }
}

// MARK: - Weekly Progress View
struct WeeklyProgressView: View {
    @ObservedObject var userProfileManager: UserProfileManager
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: PrepPalTheme.Layout.elementSpacing) {
            HStack {
                Text("Progress Overview")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Button(action: {
                    // Show detailed progress history
                }) {
                    Text("Details")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                }
            }
            
            if userProfileManager.userProfile.weeklyProgressLog.isEmpty {
                Text("No progress data yet. Your weekly summary will appear here.")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Weekly trends visualization
                weeklyTrends
            }
        }
        .padding(PrepPalTheme.Layout.basePadding)
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // Simplified weekly trends visualization
    private var weeklyTrends: some View {
        VStack(spacing: 12) {
            // Get last 4 weeks of data
            let recentWeeks = Array(userProfileManager.userProfile.weeklyProgressLog.suffix(4))
            
            // Adherence rate
            HStack {
                Text("Plan Adherence")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Spacer()
                
                ForEach(recentWeeks) { week in
                    adherenceBar(for: week.completionRate)
                }
            }
            
            // Calorie consistency
            HStack {
                Text("Calorie Target")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Spacer()
                
                ForEach(recentWeeks) { week in
                    if let goals = userProfileManager.userProfile.nutritionGoals {
                        consistencyBar(
                            actual: Double(week.averageDailyCalories),
                            target: Double(goals.calorieGoal)
                        )
                    }
                }
            }
            
            // Protein consistency
            HStack {
                Text("Protein Target")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Spacer()
                
                ForEach(recentWeeks) { week in
                    if let goals = userProfileManager.userProfile.nutritionGoals {
                        consistencyBar(
                            actual: week.averageDailyProtein,
                            target: goals.macros.protein
                        )
                    }
                }
            }
            
            // Week labels
            HStack {
                Spacer()
                
                ForEach(recentWeeks) { week in
                    Text(dateFormatter.string(from: week.date))
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .frame(width: 40)
                }
            }
        }
    }
    
    // Adherence rate visualization
    private func adherenceBar(for rate: Double) -> some View {
        let height = 60.0 * rate
        
        return VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(colorForAdherence(rate))
                .frame(width: 40, height: height)
        }
        .frame(width: 40, height: 60, alignment: .bottom)
    }
    
    // Consistency visualization
    private func consistencyBar(actual: Double, target: Double) -> some View {
        let ratio = actual / target
        let color: Color
        
        if ratio >= 0.9 && ratio <= 1.1 {
            color = PrepPalTheme.Colors.success // On target
        } else if ratio >= 0.8 && ratio <= 1.2 {
            color = PrepPalTheme.Colors.warning // Close to target
        } else {
            color = PrepPalTheme.Colors.accentRed // Off target
        }
        
        return VStack {
            Spacer()
            
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: 60)
                .overlay(
                    // Target line
                    Rectangle()
                        .fill(PrepPalTheme.Colors.gray600)
                        .frame(width: 40, height: 2)
                        .offset(y: -30) // Middle of the bar
                )
        }
        .frame(width: 40, height: 60, alignment: .bottom)
    }
    
    // Color based on adherence rate
    private func colorForAdherence(_ rate: Double) -> Color {
        if rate >= 0.9 { return PrepPalTheme.Colors.success }
        if rate >= 0.7 { return PrepPalTheme.Colors.primary }
        if rate >= 0.5 { return PrepPalTheme.Colors.warning }
        return PrepPalTheme.Colors.accentRed
    }
}

// MARK: - Goal Setting Quick Actions
struct NutritionGoalQuickActions: View {
    var onSelected: (String) -> Void
    
    private let actions = [
        "Set nutrition goals",
        "Update my macros",
        "More protein",
        "Fewer carbs",
        "Higher calories"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(actions, id: \.self) { action in
                    Button(action: {
                        onSelected(action)
                    }) {
                        Text(action)
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(PrepPalTheme.Colors.gray100)
                                    .overlay(
                                        Capsule()
                                            .stroke(PrepPalTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, PrepPalTheme.Layout.basePadding)
            .padding(.vertical, 8)
        }
    }
}
