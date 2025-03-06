import SwiftUI

// MARK: - Enhanced Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let type: MessageType
    let timestamp = Date()
    var associatedMeal: Meal? = nil
    
    enum MessageType {
        case text
        case image
        case recipeSuggestion
        case macroSuggestion
        case custom(viewType: CustomViewType)
        
        enum CustomViewType {
            case dailyMealPlan(dailyPlan: DailyMealPlan)
            case weeklyMealPlan(weeklyPlan: WeeklyMealPlan)
            case macroProgress(dailyPlan: DailyMealPlan)
        }
    }
    
    init(text: String, isUser: Bool, type: MessageType = .text, associatedMeal: Meal? = nil) {
        self.text = text
        self.isUser = isUser
        self.type = type
        self.associatedMeal = associatedMeal
    }
}

// MARK: - Enhanced Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    @State var showDetail = false
    @EnvironmentObject var userProfileManager: UserProfileManager
    
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
        .sheet(isPresented: $showDetail) {
            if let meal = message.associatedMeal {
                RecipeCardView(meal: meal)
            }
        }
    }
    
    // MARK: - Message Content
    var messageBubbleContent: some View {
        Group {
            switch message.type {
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
                
            case .custom(let viewType):
                // Custom content
                customMessageContent(for: viewType)
            }
        }
    }
    
    // Custom message content handler
    @ViewBuilder
    func customMessageContent(for viewType: ChatMessage.MessageType.CustomViewType) -> some View {
        switch viewType {
        case .dailyMealPlan(let dailyPlan):
            NutritionDashboardCard(
                dailyPlan: dailyPlan,
                showFullMealPlan: .constant(false),
                selectedMeal: .constant(nil),
                showMealDetail: .constant(false)
            )
            .padding(.horizontal, 0)
            
        case .weeklyMealPlan(let weeklyPlan):
            WeeklyMealPlanPreview(
                weeklyPlan: weeklyPlan,
                showFullMealPlan: .constant(false),
                selectedDay: .constant(nil)
            )
            .padding(.horizontal, 0)
            
        case .macroProgress(let dailyPlan):
            DailyMacroProgressCard(
                dailyPlan: dailyPlan,
                nutritionGoals: userProfileManager.userProfile.nutritionGoals
            )
            .padding(.horizontal, 0)
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
        Text(message.text)
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
            
            Text(message.text)
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
        Button(action: {
            if message.associatedMeal != nil {
                showDetail = true
            }
        }) {
            HStack(alignment: .top) {
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .font(PrepPalTheme.Typography.bodyRegular.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .multilineTextAlignment(.leading)
                    
                    Text("Tap to view this recipe suggestion")
                        .font(PrepPalTheme.Typography.caption)
                        .foregroundColor(PrepPalTheme.Colors.gray400)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Recipe Image Placeholder
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
            
            Text(message.text)
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
            text: "I need a meal prep plan for the week",
            isUser: true,
            type: .text
        ))
        
        MessageBubble(message: ChatMessage(
            text: "Here's a meal prep suggestion based on your preferences",
            isUser: false,
            type: .text
        ))
        
        MessageBubble(message: ChatMessage(
            text: "Quick Chicken Meal Prep",
            isUser: false,
            type: .recipeSuggestion
        ))
        
        MessageBubble(message: ChatMessage(
            text: "I've uploaded an image of my ingredients",
            isUser: true,
            type: .image
        ))
    }
    .padding()
    .background(PrepPalTheme.Colors.background)
}
