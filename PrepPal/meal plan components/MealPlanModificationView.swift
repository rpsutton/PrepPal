import SwiftUI

enum MealPlanModificationType: String, CaseIterable, Identifiable {
    case regenerate = "Regenerate Plan"
    case macros = "Adjust Macros"
    case schedule = "Change Schedule"
    case preferences = "Dietary Preferences"
    case servings = "Adjust Servings"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .regenerate: return "arrow.triangle.2.circlepath"
        case .macros: return "chart.bar.fill"
        case .schedule: return "calendar"
        case .preferences: return "leaf.fill"
        case .servings: return "person.2.fill"
        }
    }
    
    var prompt: String {
        switch self {
        case .regenerate: return "Generate a new meal plan with your current preferences"
        case .macros: return "Adjust the macro distribution of your meals"
        case .schedule: return "Change meal timing or weekly structure"
        case .preferences: return "Update dietary restrictions or preferences"
        case .servings: return "Adjust portion sizes or number of servings"
        }
    }
}

struct MealPlanModificationView: View {
    let plan: WeeklyMealPlan
    @Binding var isPresented: Bool
    @State private var currentModificationType: MealPlanModificationType? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                
                Text("Modify Meal Plan")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
            }
            .padding()
            .background(PrepPalTheme.Colors.cardBackground)
            .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
            
            // Option Selection or Conversation Interface
            if currentModificationType == nil {
                // Show modification options
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(MealPlanModificationType.allCases) { type in
                            Button(action: {
                                currentModificationType = type
                            }) {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: type.icon)
                                            .foregroundColor(PrepPalTheme.Colors.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(type.rawValue)
                                            .font(PrepPalTheme.Typography.bodyRegular)
                                            .foregroundColor(PrepPalTheme.Colors.gray600)
                                        
                                        Text(type.prompt)
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
                    .padding()
                }
            } else {
                // Show conversation interface for selected modification type
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(currentModificationType?.prompt ?? "How would you like to modify this meal plan?")
                            .font(PrepPalTheme.Typography.bodyRegular)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .padding()
                            .background(PrepPalTheme.Colors.assistantMessage)
                            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                        
                        // Suggestion chips based on modification type
                        suggestionChipsFor(currentModificationType!)
                    }
                    .padding()
                }
                
                // Input area
                HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                    Button(action: {
                        currentModificationType = nil
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .padding(12)
                    }
                    
                    TextField("Type your request...", text: .constant(""))
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .padding()
                        .background(PrepPalTheme.Colors.gray100)
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    
                    Button(action: {
                        // Send message action would go here
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
        }
        .background(PrepPalTheme.Colors.background)
    }
    
    private func suggestionChipsFor(_ type: MealPlanModificationType) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestionsFor(type), id: \.self) { suggestion in
                    Button(action: {
                        // Here you would trigger the actual modification request
                    }) {
                        Text(suggestion)
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(PrepPalTheme.Colors.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(PrepPalTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                                    .background(PrepPalTheme.Colors.primary.opacity(0.05))
                                    .cornerRadius(16)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func suggestionsFor(_ type: MealPlanModificationType) -> [String] {
        switch type {
        case .regenerate:
            return ["Keep breakfast", "New dinner ideas", "More variety", "Similar but healthier"]
        case .macros:
            return ["More protein", "Lower carbs", "Higher fat", "Reduce calories"]
        case .schedule:
            return ["Earlier dinners", "Later lunches", "5 meals/day", "3 meals/day"]
        case .preferences:
            return ["More vegetarian", "Less dairy", "Gluten-free", "Mediterranean style"]
        case .servings:
            return ["2 servings", "4 servings", "6 servings", "Meal prep for 5 days"]
        }
    }
}

#Preview {
    MealPlanModificationView(
        plan: WeeklyMealPlan.createSampleData(),
        isPresented: .constant(true)
    )
}
