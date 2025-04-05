import SwiftUI

struct RecipeSectionHeader: View {
    let title: String
    let section: RecipeSection
    let expandedSection: RecipeSection?
    var toggleAction: ((RecipeSection) -> Void)? = nil
    
    var body: some View {
        Button(action: {
            toggleAction?(section)
        }) {
            HStack {
                Text(title)
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Image(systemName: (expandedSection == section || expandedSection == nil) ? "chevron.up" : "chevron.down")
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .disabled(toggleAction == nil)
    }
}
