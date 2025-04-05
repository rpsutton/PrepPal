import SwiftUI

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State var selectedMeal: Meal?
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                assistantAvatar
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                messageBubbleContent
                
                // Timestamp
                Text(formatTime(message.timestamp))
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    // MARK: - Message Content
    var messageBubbleContent: some View {
        Group {
            switch message.messageType {
            case .text:
                // Regular text message
                textBubble
                
            case .image:
                // Image message
                imageMessageBubble
                
            case .recipeSuggestion:
                // Recipe suggestion
                recipeSuggestionBubble
                
            case .macroSuggestion:
                // Macro adjustment suggestion
                macroSuggestionBubble
                
            case .mealPlan(let customView):
                switch customView {
                case .weeklyMealPlan(let weeklyPlan):
                    MealPlanTimelineView(weeklyPlan: weeklyPlan)
                        .padding(.horizontal, -PrepPalTheme.Layout.basePadding)
                case .recipe(let meal):
                    RecipeCardView(meal: meal, mode: .preview)
                        .padding(.horizontal, -PrepPalTheme.Layout.basePadding)
                default:
                    textBubble
                }
            default:
                textBubble
            }
        }
    }
    
    // MARK: - Avatar
    var assistantAvatar: some View {
        ZStack {
            Circle()
                .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Image(systemName: "fork.knife")
                .foregroundColor(PrepPalTheme.Colors.primary)
                .font(.system(size: 14))
        }
    }
    
    // MARK: - Text Bubble
    var textBubble: some View {
        Text(message.content)
            .font(PrepPalTheme.Typography.bodyRegular)
            .foregroundColor(message.isUser ? PrepPalTheme.Colors.accentNavy : PrepPalTheme.Colors.gray600)
            .padding(.horizontal, PrepPalTheme.Layout.basePadding)
            .padding(.vertical, PrepPalTheme.Layout.basePadding / 1.5)
            .background(
                message.isUser ?
                    PrepPalTheme.Colors.userMessage :
                    PrepPalTheme.Colors.assistantMessage
            )
            .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .stroke(
                        message.isUser ?
                            PrepPalTheme.Colors.primary.opacity(0.1) :
                            PrepPalTheme.Colors.gray100,
                        lineWidth: 1
                    )
            )
            .shadow(color: PrepPalTheme.Colors.shadow,
                    radius: PrepPalTheme.Layout.shadowRadius/2,
                    x: 0,
                    y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Image Message Bubble
    var imageMessageBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder for actual image
            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius / 2)
                .fill(PrepPalTheme.Colors.gray100)
                .frame(width: 200, height: 120)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .font(.system(size: 30))
                )
            
            Text(message.content)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(message.isUser ? PrepPalTheme.Colors.accentNavy : PrepPalTheme.Colors.gray600)
        }
        .padding(.horizontal, PrepPalTheme.Layout.basePadding)
        .padding(.vertical, PrepPalTheme.Layout.basePadding / 1.5)
        .background(
            message.isUser ?
                PrepPalTheme.Colors.userMessage :
                PrepPalTheme.Colors.assistantMessage
        )
        .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Recipe Suggestion Bubble
    var recipeSuggestionBubble: some View {
        NavigationLink(value: message.associatedData?.mealPlan) {
            HStack(alignment: .top) {
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .font(PrepPalTheme.Typography.bodyRegular.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .multilineTextAlignment(.leading)
                    
                    Text("Tap to view this recipe suggestion")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "fork.knife.circle.fill")
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .font(.system(size: 24))
                }
            }
            .padding(.horizontal, PrepPalTheme.Layout.basePadding)
            .padding(.vertical, PrepPalTheme.Layout.basePadding / 1.2)
            .background(PrepPalTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .stroke(PrepPalTheme.Colors.primary.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: PrepPalTheme.Colors.shadow,
                    radius: PrepPalTheme.Layout.shadowRadius/2,
                    x: 0,
                    y: PrepPalTheme.Layout.shadowY/2)
        }
    }
    
    // MARK: - Macro Suggestion Bubble
    var macroSuggestionBubble: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Macro Adjustment")
                .font(PrepPalTheme.Typography.bodyRegular.bold())
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text(message.content)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            // Macro adjustments visualization
            HStack(spacing: 12) {
                MacroAdjustmentBar(label: "Protein", value: 0.2, color: PrepPalTheme.Colors.primary)
                MacroAdjustmentBar(label: "Carbs", value: -0.15, color: PrepPalTheme.Colors.accentRed)
                MacroAdjustmentBar(label: "Fat", value: 0, color: PrepPalTheme.Colors.warning)
            }
            
            Button(action: {
                // Apply adjustments
            }) {
                Text("Apply Adjustments")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PrepPalTheme.Colors.primary)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius / 2)
            }
        }
        .padding(.horizontal, PrepPalTheme.Layout.basePadding)
        .padding(.vertical, PrepPalTheme.Layout.basePadding / 1.2)
        .background(PrepPalTheme.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                .stroke(PrepPalTheme.Colors.primary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Macro Adjustment Bar
struct MacroAdjustmentBar: View {
    let label: String
    let value: Double  // Range from -1.0 to 1.0
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                
            HStack(spacing: 0) {
                if value < 0 {
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(width: 40 * abs(value), height: 8)
                    
                    Rectangle()
                        .fill(PrepPalTheme.Colors.gray100)
                        .frame(width: 40 * (1 - abs(value)), height: 8)
                } else {
                    Rectangle()
                        .fill(PrepPalTheme.Colors.gray100)
                        .frame(width: 40 * (1 - value), height: 8)
                    
                    Rectangle()
                        .fill(color.opacity(0.3))
                        .frame(width: 40 * value, height: 8)
                }
            }
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color, lineWidth: 1)
            )
            
            // Adjustment text
            Text(formatAdjustment(value))
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(value > 0 ? PrepPalTheme.Colors.success : (value < 0 ? PrepPalTheme.Colors.accentRed : PrepPalTheme.Colors.gray400))
        }
    }
    
    private func formatAdjustment(_ value: Double) -> String {
        if abs(value) < 0.01 {
            return "No change"
        }
        
        let percentage = Int(abs(value) * 100)
        return value > 0 ? "+\(percentage)%" : "-\(percentage)%"
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MessageBubble(message: ChatMessage(
            content: "I need a meal prep plan for the week",
            role: .assistant,
            messageType: .text
        ))
        
        MessageBubble(message: ChatMessage(
            content: "Here's a meal prep suggestion based on your preferences",
            role: .assistant,
            messageType: .text
        ))
        
        MessageBubble(message: ChatMessage(
            content: "Quick Chicken Meal Prep",
            role: .user,
            messageType: .recipeSuggestion
        ))
        
        MessageBubble(message: ChatMessage(
            content: "I've uploaded an image of my ingredients",
            role: .user,
            messageType: .image
        ))
    }
    .padding()
    .background(PrepPalTheme.Colors.background)
}
