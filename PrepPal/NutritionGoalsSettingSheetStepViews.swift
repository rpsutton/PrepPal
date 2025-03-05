import SwiftUI

// MARK: - Step View Extensions for NutritionGoalSettingSheet
extension NutritionGoalSettingSheet {
    
    // MARK: - Welcome Step
    var welcomeStep: some View {
        VStack(spacing: 16) {
            // Welcome illustration
            ZStack {
                Circle()
                    .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 48))
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
            .padding(.bottom, 8)
            
            Text("Let's Set Your Nutrition Goals")
                .font(PrepPalTheme.Typography.headerLarge)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .multilineTextAlignment(.center)
            
            Text("Setting your nutrition goals helps PrepPal create personalized meal plans that align perfectly with your needs and preferences.")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Description of process
            VStack(alignment: .leading, spacing: 12) {
                processStep(number: "1", text: "Tell us about yourself")
                processStep(number: "2", text: "Choose your nutrition goal")
                processStep(number: "3", text: "Select your dietary pattern")
                processStep(number: "4", text: "Review your personalized plan")
            }
            .padding()
            .background(PrepPalTheme.Colors.gray100)
            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        }
    }
    
    // MARK: - Basic Info Step
    var basicInfoStep: some View {
        VStack(spacing: 20) {
            Text("Basic Information")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text("This helps calculate your baseline nutrition needs")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
            
            // Weight input
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (kg)")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                TextField("70", value: $temporaryUserData.weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
            
            // Height input
            VStack(alignment: .leading, spacing: 8) {
                Text("Height (cm)")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                TextField("170", value: $temporaryUserData.heightCm, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
            
            // Age input
            VStack(alignment: .leading, spacing: 8) {
                Text("Age")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                TextField("30", value: $temporaryUserData.age, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
            
            // Gender selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                HStack(spacing: 12) {
                    genderButton("Male")
                    genderButton("Female")
                    genderButton("Other")
                }
            }
            
            // Activity level selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity Level")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ActivityLevel.allCases) { level in
                            activityLevelButton(level)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Goal Type Step
    var goalTypeStep: some View {
        VStack(spacing: 20) {
            Text("What's Your Goal?")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text("This helps determine your macro and calorie needs")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
            
            // Goal type options
            VStack(spacing: 12) {
                ForEach(NutritionGoals.GoalType.allCases) { goalType in
                    goalTypeButton(goalType)
                }
            }
        }
    }
    
    // MARK: - Dietary Pattern Step
    var dietaryPatternStep: some View {
        VStack(spacing: 20) {
            Text("Dietary Pattern")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text("This influences the types of foods in your meal plan")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
            
            // Dietary pattern options
            VStack(spacing: 12) {
                ForEach(NutritionGoals.DietaryPattern.allCases) { pattern in
                    dietaryPatternButton(pattern)
                }
            }
        }
    }
    
    // MARK: - Review Step
    var reviewStep: some View {
        VStack(spacing: 20) {
            Text("Your Nutrition Plan")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            // Calculate goals based on inputs
            Group {
                if let calculatedGoals = calculateGoals() {
                    // Show macro summary
                    VStack(spacing: 16) {
                        // Calorie target
                        VStack(spacing: 4) {
                            Text("Daily Calories")
                                .font(PrepPalTheme.Typography.caption)
                                .foregroundColor(PrepPalTheme.Colors.gray400)
                            
                            Text("\(calculatedGoals.calorieGoal)")
                                .font(PrepPalTheme.Typography.headerLarge)
                                .foregroundColor(PrepPalTheme.Colors.gray600)
                        }
                        
                        // Macro values
                        HStack(spacing: 20) {
                            macroDisplay(
                                value: Int(calculatedGoals.macros.protein),
                                label: "Protein",
                                color: PrepPalTheme.Colors.primary
                            )
                            
                            macroDisplay(
                                value: Int(calculatedGoals.macros.carbs),
                                label: "Carbs",
                                color: PrepPalTheme.Colors.accentRed
                            )
                            
                            macroDisplay(
                                value: Int(calculatedGoals.macros.fat),
                                label: "Fat",
                                color: PrepPalTheme.Colors.warning
                            )
                        }
                    }
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    
                    // Plan summary
                    VStack(alignment: .leading, spacing: 12) {
                        summaryRow(
                            icon: "target",
                            title: "Goal Type",
                            value: calculatedGoals.goalType.rawValue
                        )
                        
                        summaryRow(
                            icon: "leaf",
                            title: "Dietary Pattern",
                            value: calculatedGoals.dietaryPattern.rawValue
                        )
                        
                        summaryRow(
                            icon: "figure.walk",
                            title: "Activity Level",
                            value: temporaryUserData.activityLevel?.rawValue ?? "Not specified"
                        )
                        
                        // Basic metrics summary
                        if let weight = temporaryUserData.weight,
                           let height = temporaryUserData.heightCm {
                            summaryRow(
                                icon: "scalemass",
                                title: "Metrics",
                                value: "\(Int(weight))kg • \(Int(height))cm • \(temporaryUserData.age ?? 0) years"
                            )
                        }
                    }
                    .padding()
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    
                    // Customization button
                    Button(action: {
                        showingCustomization = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Fine-tune Your Plan")
                        }
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(PrepPalTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    }
                    .sheet(isPresented: $showingCustomization) {
                        MacroCustomizationView(
                            goals: calculatedGoals,
                            isPresented: $showingCustomization,
                            onSave: { updatedGoals in
                                // Store the custom goals
                                saveGoals(updatedGoals)
                            }
                        )
                    }
                } else {
                    Text("Please complete all required fields")
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.accentRed)
                }
            }
        }
    }
}
