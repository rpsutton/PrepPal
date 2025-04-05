import SwiftUI

public struct QuickActions: View {
    let actions: [String]
    let onSelect: (String) -> Void
    
    // Map of actions to their respective icons
    private let actionIcons: [String: (icon: String, color: Color)] = [
        "Set nutrition goals": ("chart.bar.fill", PrepPalTheme.Colors.primary),
        "Meal prep ideas": ("fork.knife", PrepPalTheme.Colors.secondary),
        "Healthy snacks": ("leaf.fill", PrepPalTheme.Colors.success)
    ]
    
    public init(actions: [String], onSelect: @escaping (String) -> Void) {
        self.actions = actions
        self.onSelect = onSelect
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {            
            // Suggestions scroll view
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PrepPalTheme.Layout.elementSpacing/2) {
                    ForEach(actions, id: \.self) { action in
                        ActionChip(
                            text: action,
                            icon: actionIcons[action]?.icon ?? "bubble.left.fill",
                            iconColor: actionIcons[action]?.color ?? PrepPalTheme.Colors.primary,
                            action: { onSelect(action) }
                        )
                    }
                }
                .padding(.horizontal, PrepPalTheme.Layout.basePadding)
                .padding(.bottom, 12)
            }
        }
        .padding(.top, 8)
        .background(
            Rectangle()
                .fill(PrepPalTheme.Colors.cardBackground)
                .overlay(
                    LinearGradient(
                        colors: [
                            PrepPalTheme.Colors.primary.opacity(0.02),
                            PrepPalTheme.Colors.cardBackground
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(
                    color: PrepPalTheme.Colors.shadow,
                    radius: PrepPalTheme.Layout.shadowRadius/2,
                    y: PrepPalTheme.Layout.shadowY/2
                )
        )
    }
}

// MARK: - Action Chip (Internal Component)
private struct ActionChip: View {
    let text: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                action()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 6) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(iconColor)
                
                // Text
                Text(text)
                    .font(PrepPalTheme.Typography.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, PrepPalTheme.Layout.pillPadding)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.pillCornerRadius)
                    .fill(PrepPalTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PrepPalTheme.Layout.pillCornerRadius)
                            .stroke(PrepPalTheme.Colors.border, lineWidth: 1)
                    )
                    .shadow(
                        color: PrepPalTheme.Colors.shadow,
                        radius: isPressed ? 1 : 2,
                        y: isPressed ? 0 : 1
                    )
            )
            .foregroundColor(PrepPalTheme.Colors.gray600)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

#Preview {
    QuickActions(
        actions: [
            "Set nutrition goals",
            "Meal prep ideas",
            "Healthy snacks"
        ]
    ) { action in
        print("Selected: \(action)")
    }
    .background(PrepPalTheme.Colors.background)
}
