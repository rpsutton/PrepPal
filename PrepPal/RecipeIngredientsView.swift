import SwiftUI

struct RecipeIngredientsView: View {
    let meal: Meal
    let expandedSection: RecipeSection?
    @Binding var checkedIngredients: Set<Int>
    var toggleAction: ((RecipeSection) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            RecipeSectionHeader(title: "Ingredients", section: .ingredients, expandedSection: expandedSection, toggleAction: toggleAction)
            
            if expandedSection == .ingredients || expandedSection == nil {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(meal.ingredients.enumerated()), id: \.element) { index, ingredient in
                        HStack(alignment: .top, spacing: 12) {
                            Button(action: {
                                toggleIngredient(index)
                            }) {
                                Image(systemName: checkedIngredients.contains(index) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(checkedIngredients.contains(index) ? PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                                    .imageScale(.large)
                            }
                            
                            Text(ingredient)
                                .font(PrepPalTheme.Typography.bodyRegular)
                                .foregroundColor(checkedIngredients.contains(index) ? PrepPalTheme.Colors.gray400 : PrepPalTheme.Colors.gray600)
                                .strikethrough(checkedIngredients.contains(index))
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    // Toggle ingredient checked state
    private func toggleIngredient(_ index: Int) {
        if checkedIngredients.contains(index) {
            checkedIngredients.remove(index)
        } else {
            checkedIngredients.insert(index)
        }
    }
}
