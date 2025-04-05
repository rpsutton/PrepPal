import SwiftUI

// MARK: - Nutrition Goal Quick Actions
public struct NutritionGoalQuickActions: View {
    let onSelected: (String) -> Void
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                quickActionButton("Set nutrition goals")
                quickActionButton("Show macro progress")
                quickActionButton("Today's meal plan")
                quickActionButton("Weekly meal plan")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(PrepPalTheme.Colors.gray100)
    }
    
    private func quickActionButton(_ title: String) -> some View {
        Button(action: {
            onSelected(title)
        }) {
            Text(title)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                )
        }
    }
}

// MARK: - Chat Input Bar Extension
public extension ChatInputBar {
    // Add nutrition goal quick action suggestions
    func withNutritionGoalQuickActions(onSelected: @escaping (String) -> Void) -> some View {
        VStack(spacing: 0) {
            // Quick actions for nutrition goals
            NutritionGoalQuickActions(onSelected: onSelected)
            
            // Original chat input bar
            self
        }
    }
}
