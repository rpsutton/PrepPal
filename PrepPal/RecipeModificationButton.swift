import SwiftUI

struct RecipeModificationButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(PrepPalTheme.Colors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: PrepPalTheme.Colors.shadow.opacity(0.3), radius: 4, y: 2)
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
            }
        }
    }
}

