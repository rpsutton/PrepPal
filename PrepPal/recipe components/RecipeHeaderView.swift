import SwiftUI

struct RecipeHeaderView: View {
    let meal: Meal
    let totalTime: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Placeholder for image - in production, you'd use AsyncImage or Image with actual resource
            Color(PrepPalTheme.Colors.primary.opacity(0.8))
                .frame(height: 200)
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            
            // Recipe title and quick stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(PrepPalTheme.Typography.headerLarge)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label("\(totalTime) min", systemImage: "clock")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(.white)
                        
                        Label("4 servings", systemImage: "person.2")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(PrepPalTheme.Layout.basePadding)
        }
    }
}

