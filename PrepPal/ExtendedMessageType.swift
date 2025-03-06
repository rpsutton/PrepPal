//
//  ExtendedMessageType.swift
//  PrepPal
//
//  Created by Paul Sutton on 2/26/25.
//

import SwiftUI

// MARK: - Nutrition Goal Chat Extension
extension ChatMessage {
    // Add new message type for nutrition goals
    enum ExtendedMessageType {
        case nutritionGoalSetting
        case nutritionGoalUpdate
        case nutritionProgress
    }
    
    // Create a nutrition goal setting message
    static func createNutritionGoalMessage(isUser: Bool, type: ExtendedMessageType, nutritionGoals: NutritionGoals? = nil) -> ChatMessage {
        let text: String
        let messageType: MessageType
        
        switch type {
        case .nutritionGoalSetting:
            text = isUser ? "I want to set my nutrition goals" : "Let's set up your nutrition goals."
            messageType = .macroSuggestion
            
        case .nutritionGoalUpdate:
            text = isUser ? "I want to update my nutrition plan" : "Here's your updated nutrition plan."
            messageType = .macroSuggestion
            
        case .nutritionProgress:
            text = isUser ? "How am I doing with my nutrition?" : "Here's your nutrition progress."
            messageType = .macroSuggestion
        }
        
        return ChatMessage(text: text, isUser: isUser, type: messageType)
    }
}

// MARK: - Nutrition Goal Chat Message View
struct NutritionGoalChatMessageView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    let message: ChatMessage
    let onSetGoals: () -> Void
    let onAdjustGoals: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Message text
            Text(message.text)
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            // Nutrition goal card or prompt
            if let nutritionGoals = userProfileManager.userProfile.nutritionGoals {
                // Compact nutrition goal summary
                nutritionGoalSummary(nutritionGoals)
            } else {
                // Prompt to set goals
                nutritionGoalPrompt
            }
            
            // Action buttons
            HStack(spacing: 12) {
                if userProfileManager.userProfile.nutritionGoals != nil {
                    Button(action: onAdjustGoals) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Adjust Goals")
                        }
                        .font(PrepPalTheme.Typography.caption.bold())
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PrepPalTheme.Colors.primary.opacity(0.1))
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    }
                } else {
                    Button(action: onSetGoals) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Set Goals")
                        }
                        .font(PrepPalTheme.Typography.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PrepPalTheme.Colors.primary)
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    }
                }
                
                // View progress button (if goals exist)
                if userProfileManager.userProfile.nutritionGoals != nil {
                    Button(action: {
                        // Show detailed progress
                    }) {
                        HStack {
                            Image(systemName: "chart.xyaxis.line")
                            Text("View Progress")
                        }
                        .font(PrepPalTheme.Typography.caption.bold())
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(PrepPalTheme.Colors.gray100)
                        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    }
                }
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Nutrition goal summary card
    private func nutritionGoalSummary(_ goals: NutritionGoals) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(goals.goalType.rawValue) • \(goals.dietaryPattern.rawValue)")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                Text("\(goals.calorieGoal) calories")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
            
            HStack(spacing: 12) {
                macroSummaryPill(
                    value: Int(goals.macros.protein),
                    label: "Protein",
                    color: PrepPalTheme.Colors.primary
                )
                
                macroSummaryPill(
                    value: Int(goals.macros.carbs),
                    label: "Carbs",
                    color: PrepPalTheme.Colors.accentRed
                )
                
                macroSummaryPill(
                    value: Int(goals.macros.fat),
                    label: "Fat",
                    color: PrepPalTheme.Colors.warning
                )
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.gray100)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Nutrition goal prompt
    private var nutritionGoalPrompt: some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(PrepPalTheme.Colors.info)
            
            Text("Setting your nutrition goals helps me create personalized meal plans that align with your needs.")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
        }
        .padding()
        .background(PrepPalTheme.Colors.info.opacity(0.1))
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    // Macro summary pill
    private func macroSummaryPill(value: Int, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(value)g")
                .font(PrepPalTheme.Typography.caption.bold())
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray400)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.pillCornerRadius)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.pillCornerRadius)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Message Detector Extension
extension String {
    // Detect if the message is related to nutrition goals
    func isNutritionGoalRelated() -> Bool {
        let lowercased = self.lowercased()
        
        // Keywords related to nutrition goals
        let nutritionKeywords = [
            "nutrition", "macros", "calories", "protein",
            "carbs", "fat", "diet", "weight", "goals",
            "target", "eating plan", "meal plan"
        ]
        
        // Action verbs related to goals
        let actionVerbs = [
            "set", "change", "update", "adjust", "modify",
            "track", "increase", "decrease", "lower"
        ]
        
        // Check for combination of nutrition keywords and action verbs
        let hasNutritionKeyword = nutritionKeywords.contains { lowercased.contains($0) }
        let hasActionVerb = actionVerbs.contains { lowercased.contains($0) }
        
        // Direct goal setting phrases
        let directPhrases = [
            "need more protein",
            "want to lose weight",
            "want to gain muscle",
            "my diet goals",
            "how many calories",
            "set my goals"
        ]
        
        let hasDirectPhrase = directPhrases.contains { lowercased.contains($0) }
        
        return (hasNutritionKeyword && hasActionVerb) || hasDirectPhrase
    }
}

// MARK: - Chat Controller Extension
class ChatController {
    // Extract nutrition goal intent from user message
    func extractNutritionGoalIntent(from message: String) -> NutritionGoalIntent? {
        let lowercased = message.lowercased()
        
        // Set new goals
        if lowercased.contains("set") && (lowercased.contains("goal") || lowercased.contains("target")) {
            return .setNew
        }
        
        // Update existing goals
        if (lowercased.contains("update") || lowercased.contains("change") || lowercased.contains("modify")) &&
           (lowercased.contains("goal") || lowercased.contains("target") || lowercased.contains("macros")) {
            return .update
        }
        
        // Increase specific macros
        if lowercased.contains("more") || lowercased.contains("increase") || lowercased.contains("higher") {
            if lowercased.contains("protein") {
                return .increaseProtein
            } else if lowercased.contains("carb") {
                return .increaseCarbs
            } else if lowercased.contains("fat") {
                return .increaseFat
            } else if lowercased.contains("calorie") {
                return .increaseCalories
            }
        }
        
        // Decrease specific macros
        if lowercased.contains("less") || lowercased.contains("decrease") || lowercased.contains("lower") || lowercased.contains("fewer") {
            if lowercased.contains("protein") {
                return .decreaseProtein
            } else if lowercased.contains("carb") {
                return .decreaseCarbs
            } else if lowercased.contains("fat") {
                return .decreaseFat
            } else if lowercased.contains("calorie") {
                return .decreaseCalories
            }
        }
        
        // View progress
        if (lowercased.contains("show") || lowercased.contains("view") || lowercased.contains("how am i doing")) &&
           (lowercased.contains("progress") || lowercased.contains("tracking")) {
            return .viewProgress
        }
        
        // Change diet type
        if (lowercased.contains("change") || lowercased.contains("switch")) &&
           (lowercased.contains("diet") || lowercased.contains("eating")) {
            return .changeDietType
        }
        
        return nil
    }
    
    enum NutritionGoalIntent {
        case setNew
        case update
        case increaseProtein
        case decreaseProtein
        case increaseCarbs
        case decreaseCarbs
        case increaseFat
        case decreaseFat
        case increaseCalories
        case decreaseCalories
        case viewProgress
        case changeDietType
    }
}
