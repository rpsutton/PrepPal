import SwiftUI

struct RecipeModificationView: View {
    let meal: Meal
    @Binding var isPresented: Bool
    @State private var currentModificationType: ModificationType? = nil
    
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
                
                Text("Change This Recipe")
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
                        ForEach(ModificationType.allCases) { type in
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
                        Text(currentModificationType?.prompt ?? "How would you like to modify this recipe?")
                            .font(PrepPalTheme.Typography.bodyRegular)
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .padding()
                            .background(PrepPalTheme.Colors.assistantMessage)
                            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                        
                        // Suggested inputs based on modification type
                        if let type = currentModificationType {
                            suggestionChipsForType(type)
                        }
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
    
    // MARK: - Suggestion Chips
    private func suggestionChipsForType(_ type: ModificationType) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestionsFor(type), id: \.self) { suggestion in
                    Button(action: {
                        // Here you would trigger the actual modification request
                        // For example, sending the suggestion to your AI assistant
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
    
    private func suggestionsFor(_ type: ModificationType) -> [String] {
        switch type {
        case .macros:
            return ["More protein", "Fewer carbs", "Lower fat", "Higher protein, lower carbs"]
        case .ingredients:
            return meal.ingredients.map { ingredient -> String in
                let parts = ingredient.split(separator: " ")
                if let last = parts.last {
                    return "Replace \(last)"
                }
                return "Replace ingredient"
            }
        case .flavor:
            return ["Make it spicy", "Mediterranean style", "Asian-inspired", "Make it sweeter"]
        case .dietary:
            return ["Make it gluten-free", "Make it vegan", "Make it keto", "Low sodium"]
        case .servings:
            return ["2 servings", "4 servings", "6 servings", "Meal prep for 5 days"]
        }
    }
}
