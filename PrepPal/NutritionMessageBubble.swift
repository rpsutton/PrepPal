import SwiftUI

// MARK: - Extension to MessageBubble to support Nutrition Goal Messages
extension MessageBubble {
    // This extension allows the MessageBubble to handle nutrition goal messages
    @ViewBuilder
    var messageContent: some View {
        if let nutritionMessageType = extractNutritionMessageType() {
            NutritionGoalChatMessageView(
                message: message,
                onSetGoals: {
                    // Implement showing the NutritionGoalSettingSheet
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowNutritionGoalSheet"),
                        object: nil
                    )
                },
                onAdjustGoals: {
                    // Implement showing the NutritionGoalSettingSheet with existing data
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ShowNutritionGoalSheet"),
                        object: nil
                    )
                }
            )
        } else {
            // Original message content based on type
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
            }
        }
    }
    
    // Helper to identify nutrition goal messages
    private func extractNutritionMessageType() -> ChatMessage.ExtendedMessageType? {
        // Check if the message is a nutrition-related message
        if message.type == .macroSuggestion {
            let text = message.text.lowercased()
            
            if text.contains("set") && text.contains("nutrition") && text.contains("goals") {
                return .nutritionGoalSetting
            } else if text.contains("update") && (text.contains("nutrition") || text.contains("goals")) {
                return .nutritionGoalUpdate
            } else if text.contains("progress") && text.contains("nutrition") {
                return .nutritionProgress
            }
        }
        
        return nil
    }
}

// MARK: - Update to ChatView for Notification Handling
extension ChatView {
    // Set up observers for nutrition goal sheet notifications
    func setupNutritionGoalNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ShowNutritionGoalSheet"),
            object: nil,
            queue: .main
        ) { _ in
            self.isShowingNutritionGoalSheet = true
        }
    }
    
    // Call this in .onAppear in ChatView
    func onAppearSetup() {
        addWelcomeMessage()
        checkForNutritionGoals()
        setupNutritionGoalNotifications()
    }
}

// MARK: - MessageBubble Body Update
// Add this to replace the current body implementation in MessageBubble
extension MessageBubble {
    var updatedBody: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                assistantAvatar
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Use the new messageContent property
                messageContent
                
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
}
