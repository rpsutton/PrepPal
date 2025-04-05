import SwiftUI

// MARK: - UI Components for NutritionGoalSettingSheet
extension NutritionGoalSettingSheet {
    
    // MARK: - Process Step
    func processStep(number: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(PrepPalTheme.Colors.primary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .stroke(PrepPalTheme.Colors.primary, lineWidth: 2)
                )
            
            Text(text)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
        }
    }
    
    // MARK: - Gender Button
    func genderButton(_ gender: String) -> some View {
        Button(action: {
            temporaryUserData.gender = gender
        }) {
            Text(gender)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(temporaryUserData.gender == gender ?
                               .white : PrepPalTheme.Colors.gray600)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                        .fill(temporaryUserData.gender == gender ?
                            PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray100)
                )
        }
    }
    
    // MARK: - Activity Level Button
    func activityLevelButton(_ level: ActivityLevel) -> some View {
        Button(action: {
            temporaryUserData.activityLevel = level
        }) {
            VStack(spacing: 8) {
                Image(systemName: activityLevelIcon(for: level))
                    .font(.system(size: 24))
                    .foregroundColor(temporaryUserData.activityLevel == level ?
                                   PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                
                Text(activityLevelShortName(for: level))
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(temporaryUserData.activityLevel == level ?
                                   PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
            }
            .padding()
            .frame(width: 100)
            .background(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .fill(temporaryUserData.activityLevel == level ?
                        PrepPalTheme.Colors.primary.opacity(0.1) : PrepPalTheme.Colors.gray100)
                    .overlay(
                        RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                            .stroke(temporaryUserData.activityLevel == level ?
                                  PrepPalTheme.Colors.primary : Color.clear, lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Goal Type Button
    func goalTypeButton(_ goalType: NutritionGoals.GoalType) -> some View {
        Button(action: {
            temporaryUserData.goalType = goalType
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(temporaryUserData.goalType == goalType ?
                             PrepPalTheme.Colors.primary.opacity(0.2) : PrepPalTheme.Colors.gray100)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: goalTypeIcon(for: goalType))
                        .font(.system(size: 20))
                        .foregroundColor(temporaryUserData.goalType == goalType ?
                                       PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(goalType.rawValue)
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    Text(goalType.description)
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Selected indicator
                if temporaryUserData.goalType == goalType {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PrepPalTheme.Colors.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .fill(temporaryUserData.goalType == goalType ?
                        PrepPalTheme.Colors.primary.opacity(0.05) : PrepPalTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                            .stroke(temporaryUserData.goalType == goalType ?
                                  PrepPalTheme.Colors.primary : PrepPalTheme.Colors.border, lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Dietary Pattern Button
    func dietaryPatternButton(_ pattern: NutritionGoals.DietaryPattern) -> some View {
        Button(action: {
            temporaryUserData.dietaryPattern = pattern
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(temporaryUserData.dietaryPattern == pattern ?
                             PrepPalTheme.Colors.primary.opacity(0.2) : PrepPalTheme.Colors.gray100)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: dietaryPatternIcon(for: pattern))
                        .font(.system(size: 20))
                        .foregroundColor(temporaryUserData.dietaryPattern == pattern ?
                                       PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(pattern.rawValue)
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                    
                    macroDistributionIndicator(for: pattern)
                }
                
                Spacer()
                
                // Selected indicator
                if temporaryUserData.dietaryPattern == pattern {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(PrepPalTheme.Colors.primary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .fill(temporaryUserData.dietaryPattern == pattern ?
                        PrepPalTheme.Colors.primary.opacity(0.05) : PrepPalTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                            .stroke(temporaryUserData.dietaryPattern == pattern ?
                                  PrepPalTheme.Colors.primary : PrepPalTheme.Colors.border, lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Macro Distribution Indicator
    func macroDistributionIndicator(for pattern: NutritionGoals.DietaryPattern) -> some View {
        let distribution = pattern.macroDistribution
        
        return HStack(spacing: 8) {
            Text("P: \(Int(distribution.protein * 100))%")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.primary.opacity(0.8))
            
            Text("C: \(Int(distribution.carbs * 100))%")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.accentRed.opacity(0.8))
            
            Text("F: \(Int(distribution.fat * 100))%")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.warning.opacity(0.8))
        }
    }
    
    // Icons and names
    func activityLevelIcon(for level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return "figure.stand"
        case .light: return "figure.walk"
        case .moderate: return "figure.hiking"
        case .active: return "figure.run"
        case .veryActive: return "figure.highintensity.intervaltraining"
        }
    }
    
    func activityLevelShortName(for level: ActivityLevel) -> String {
        switch level {
        case .sedentary: return "Sedentary"
        case .light: return "Light"
        case .moderate: return "Moderate"
        case .active: return "Active"
        case .veryActive: return "Very Active"
        }
    }
    
    func goalTypeIcon(for goalType: NutritionGoals.GoalType) -> String {
        switch goalType {
        case .weightLoss: return "arrow.down.circle"
        case .maintenance: return "equal.circle"
        case .muscleGain: return "arrow.up.circle"
        case .athletic: return "figure.mixed.cardio"
        case .custom: return "slider.horizontal.3"
        }
    }
    
    func dietaryPatternIcon(for pattern: NutritionGoals.DietaryPattern) -> String {
        switch pattern {
        case .balanced: return "circle.grid.2x2"
        case .lowCarb: return "chart.pie"
        case .keto: return "chart.pie.fill"
        case .highProtein: return "fork.knife"
        case .vegetarian: return "leaf"
        case .vegan: return "leaf.fill"
        case .paleo: return "clock.arrow.circlepath"
        case .mediterranean: return "fish"
        }
    }

    // MARK: - Macro Display
    func macroDisplay(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)g")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // MARK: - Summary Row
    func summaryRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(PrepPalTheme.Colors.primary)
                .frame(width: 24)
            
            Text(title)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
            
            Text(value)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
        }
    }
}
