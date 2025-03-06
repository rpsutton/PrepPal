import SwiftUI

// MARK: - Chat View Extensions for Meal Plans
extension ChatView {
    // MARK: - Render Meal Plan in Chat
    func renderDailyMealPlanMessage() {
        // Create a message containing the daily meal plan
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayName = dateFormatter.string(from: today)
        
        // Find today's meal plan from the weekly data
        if let todayPlan = weeklyMealPlan.dailyPlans.first(where: { $0.day == dayName }) {
            let dailyPlanMessage = ChatMessage(
                text: "Here's your meal plan for today",
                isUser: false,
                type: ChatMessage.MessageType.text
            )
            messages.append(dailyPlanMessage)
            
            // Let the message render, then after a small delay add the plan card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let cardMessage = ChatMessage(
                    text: "Daily Meal Plan Card",
                    isUser: false,
                    type: ChatMessage.MessageType.custom(viewType: .dailyMealPlan(dailyPlan: todayPlan))
                )
                self.messages.append(cardMessage)
            }
        }
    }
    
    func renderWeeklyMealPlanMessage() {
        let weeklyPlanMessage = ChatMessage(
            text: "Here's your meal plan for the week",
            isUser: false,
            type: ChatMessage.MessageType.text
        )
        messages.append(weeklyPlanMessage)
        
        // Let the message render, then after a small delay add the plan card
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let cardMessage = ChatMessage(
                text: "Weekly Meal Plan Overview",
                isUser: false,
                type: ChatMessage.MessageType.custom(viewType: .weeklyMealPlan(weeklyPlan: self.weeklyMealPlan))
            )
            self.messages.append(cardMessage)
        }
    }
    
    func renderMacroProgressMessage() {
        // Create a message containing macro progress
        let progressMessage = ChatMessage(
            text: "Here's your nutrition progress for today",
            isUser: false,
            type: ChatMessage.MessageType.text
        )
        messages.append(progressMessage)
        
        // Get today's plan for the progress data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayName = dateFormatter.string(from: Date())
        
        if let todayPlan = weeklyMealPlan.dailyPlans.first(where: { $0.day == dayName }) {
            // Let the message render, then after a small delay add the progress card
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let cardMessage = ChatMessage(
                    text: "Macro Progress",
                    isUser: false,
                    type: ChatMessage.MessageType.custom(viewType: .macroProgress(dailyPlan: todayPlan))
                )
                self.messages.append(cardMessage)
            }
        }
    }
    
    // MARK: - Process User Message
    func processMealPlanMessage(_ message: String) {
        // Check for meal plan related queries
        let lowercased = message.lowercased()
        
        if lowercased.contains("meal plan") || (lowercased.contains("meal") && lowercased.contains("plan")) {
            if lowercased.contains("today") || lowercased.contains("day") {
                renderDailyMealPlanMessage()
            } else if lowercased.contains("week") {
                renderWeeklyMealPlanMessage()
            } else {
                // Default to daily plan if unclear
                renderDailyMealPlanMessage()
            }
        } else if lowercased.contains("macro") && (lowercased.contains("progress") || lowercased.contains("status")) {
            renderMacroProgressMessage()
        } else if (lowercased.contains("how") && lowercased.contains("doing")) ||
                  (lowercased.contains("nutrition") && lowercased.contains("progress")) {
            renderMacroProgressMessage()
        } else {
            // Regular processing for non-meal plan messages
            processWithAI(message)
        }
    }
    
    // Enhance the existing sendMessage function in ChatView
    func enhanceSendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(
            text: messageText,
            isUser: true,
            type: ChatMessage.MessageType.text
        )
        messages.append(userMessage)
        
        // Clear input
        let sentMessage = messageText
        messageText = ""
        
        // Hide hint after user interaction
        showNutritionTriggerHint = false
        
        // Start loading state
        isLoading = true
        
        // Check if message is about nutrition goals
        if isNutritionGoalMessage(sentMessage) {
            handleNutritionGoalMessage(sentMessage)
        } else if isMealPlanMessage(sentMessage) {
            // Process meal plan messages
            isLoading = false
            processMealPlanMessage(sentMessage)
        } else {
            // Process through regular AI flow
            processWithAI(sentMessage)
        }
    }
    
    func isMealPlanMessage(_ message: String) -> Bool {
        let lowercased = message.lowercased()
        
        // Keywords related to meal plans
        let mealPlanKeywords = ["meal plan", "meal", "plan", "macro", "progress", "today", "week", "food", "eating"]
        let actionKeywords = ["show", "see", "view", "how", "tell", "display"]
        
        // Check for a combination of keywords
        let hasMealPlanKeyword = mealPlanKeywords.contains { lowercased.contains($0) }
        let hasActionKeyword = actionKeywords.contains { lowercased.contains($0) }
        
        return hasMealPlanKeyword && hasActionKeyword
    }
}
