import SwiftUI

// MARK: - Macro Customization View
struct MacroCustomizationView: View {
    let goals: NutritionGoals
    @Binding var isPresented: Bool
    let onSave: (NutritionGoals) -> Void
    
    // Use private state variables for the macro values
    @State private var protein: Double
    @State private var carbs: Double
    @State private var fat: Double
    @State private var calories: Double // Changed to Double for consistency
    
    init(goals: NutritionGoals, isPresented: Binding<Bool>, onSave: @escaping (NutritionGoals) -> Void) {
        self.goals = goals
        self._isPresented = isPresented
        self.onSave = onSave
        
        // Initialize state with current values - fixed initialization syntax
        self._protein = State(initialValue: goals.macros.protein)
        self._carbs = State(initialValue: goals.macros.carbs)
        self._fat = State(initialValue: goals.macros.fat)
        self._calories = State(initialValue: Double(goals.calorieGoal)) // Convert Int to Double
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    Text("Adjust your macronutrients to match your specific preferences.")
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Calorie slider
                    calorieSlider
                    
                    // Protein slider
                    macroSlider(
                        title: "Protein (g)",
                        value: $protein,
                        range: goals.macros.protein * 0.7...goals.macros.protein * 1.5,
                        step: 5,
                        color: PrepPalTheme.Colors.primary
                    )
                    
                    // Carbs slider
                    macroSlider(
                        title: "Carbs (g)",
                        value: $carbs,
                        range: goals.macros.carbs * 0.5...goals.macros.carbs * 1.5,
                        step: 5,
                        color: PrepPalTheme.Colors.accentRed
                    )
                    
                    // Fat slider
                    macroSlider(
                        title: "Fat (g)",
                        value: $fat,
                        range: goals.macros.fat * 0.7...goals.macros.fat * 1.5,
                        step: 3,
                        color: PrepPalTheme.Colors.warning
                    )
                    
                    // Macro distribution chart
                    distributionChart
                    
                    // Action buttons
                    actionButtons
                }
                .padding()
            }
        }
    }
    
    // MARK: - Subviews
    
    // Header view
    private var headerView: some View {
        ZStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                }
                Spacer()
            }
            
            Text("Fine-tune Your Macros")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    // Calorie slider view
    private var calorieSlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Calories")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text("\(Int(calories))")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
            
            // Breaking up the complex expression
            let minCalories = Double(goals.calorieGoal) * 0.7
            let maxCalories = Double(goals.calorieGoal) * 1.3
            
            Slider(
                value: $calories,
                in: minCalories...maxCalories,
                step: 50
            )
            .accentColor(PrepPalTheme.Colors.primary)
            
            HStack {
                Text("\(Int(Double(goals.calorieGoal) * 0.7))")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Spacer()
                
                Text("\(Int(Double(goals.calorieGoal) * 1.3))")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Distribution chart view
    private var distributionChart: some View {
        VStack(spacing: 12) {
            Text("Macronutrient Distribution")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            HStack(spacing: 20) {
                // Pie chart visualization
                pieChart
                
                // Percentages
                VStack(alignment: .leading, spacing: 8) {
                    macroPercentage(
                        label: "Protein",
                        value: calculatePercentage(protein * 4),
                        color: PrepPalTheme.Colors.primary
                    )
                    
                    macroPercentage(
                        label: "Carbs",
                        value: calculatePercentage(carbs * 4),
                        color: PrepPalTheme.Colors.accentRed
                    )
                    
                    macroPercentage(
                        label: "Fat",
                        value: calculatePercentage(fat * 9),
                        color: PrepPalTheme.Colors.warning
                    )
                }
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Action buttons view
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Cancel button
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
            
            // Save button
            Button(action: {
                saveCustomGoals()
                isPresented = false
            }) {
                Text("Save Changes")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(PrepPalTheme.Colors.primary)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
        }
    }
    
    // MARK: - Helper Views
    
    // Macro slider component
    private func macroSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text("\(Int(value.wrappedValue))g")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(color)
            }
            
            Slider(value: value, in: range, step: step)
                .accentColor(color)
            
            HStack {
                Text("\(Int(range.lowerBound))g")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                Spacer()
                
                Text("\(Int(range.upperBound))g")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Pie chart visualization
    private var pieChart: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: calculatePieSlice(for: "protein"))
                .stroke(PrepPalTheme.Colors.primary, lineWidth: 12)
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: calculatePieSlice(for: "protein"),
                      to: calculatePieSlice(for: "protein") + calculatePieSlice(for: "carbs"))
                .stroke(PrepPalTheme.Colors.accentRed, lineWidth: 12)
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
            
            Circle()
                .trim(from: calculatePieSlice(for: "protein") + calculatePieSlice(for: "carbs"),
                      to: 1)
                .stroke(PrepPalTheme.Colors.warning, lineWidth: 12)
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
            
            // Total calories
            VStack(spacing: 0) {
                Text("\(calculateTotalCalories())")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Text("calories")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
            }
        }
    }
    
    // Macro percentage display
    private func macroPercentage(label: String, value: Int, color: Color) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(color)
                .frame(width: 12, height: 12)
                .cornerRadius(2)
            
            Text(label)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
            
            Text("\(value)%")
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(color)
        }
    }
    
    // MARK: - Helper Methods
    
    // Calculate pie chart slice sizes
    private func calculatePieSlice(for macroType: String) -> Double {
        let proteinCals = protein * 4
        let carbsCals = carbs * 4
        let fatCals = fat * 9
        let totalCals = Double(calculateTotalCalories())
        
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
    
    // Calculate total calories
    private func calculateTotalCalories() -> Int {
        return Int((protein * 4) + (carbs * 4) + (fat * 9))
    }
    
    // Calculate percentage of calories from a macro
    private func calculatePercentage(_ macroCalories: Double) -> Int {
        let totalCals = Double(calculateTotalCalories())
        return Int((macroCalories / totalCals) * 100)
    }
    
    // Save custom goals
    private func saveCustomGoals() {
        // Create a mutable copy of the goals structure
        let macros = MacroGoal(
            protein: protein,
            carbs: carbs,
            fat: fat,
            calories: calculateTotalCalories()
        )
        
        // Create a new NutritionGoals object with updated values
        let updatedGoals = NutritionGoals(
            macros: macros,
            calorieGoal: calculateTotalCalories(),
            targetProteinPerKg: goals.targetProteinPerKg,
            targetCarbs: Int(carbs),
            targetFat: Int(fat),
            goalType: goals.goalType,
            dietaryPattern: goals.dietaryPattern
        )
        
        // Save using the provided callback
        onSave(updatedGoals)
    }
}
