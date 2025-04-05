import SwiftUI

struct RecipeDescriptionView: View {
    let meal: Meal
    let expandedSection: RecipeSection?
    var toggleAction: ((RecipeSection) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            RecipeSectionHeader(title: "Overview", section: .description, expandedSection: expandedSection, toggleAction: toggleAction)
            
            if expandedSection == .description || expandedSection == nil {
                Text(meal.description)
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                    .padding(.bottom, 8)
                
                // Macro summary
                macroSummary
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    // MARK: - Macro Summary
    private var macroSummary: some View {
        HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
            macroInfoBox(title: "Calories", value: "\(meal.calories)")
            macroInfoBox(title: "Protein", value: "\(Int(meal.macros.protein))g")
            macroInfoBox(title: "Carbs", value: "\(Int(meal.macros.carbs))g")
            macroInfoBox(title: "Fat", value: "\(Int(meal.macros.fat))g")
        }
        .padding(.vertical, 12)
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    private func macroInfoBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            Text(title)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray400)
        }
        .frame(maxWidth: .infinity)
    }
}
