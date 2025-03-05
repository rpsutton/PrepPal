import SwiftUI

// MARK: - Goal Setting Conversation Handler
class GoalSettingConversation: ObservableObject {
    @Published var conversationState: ConversationState = .initial
    @Published var temporaryUserData: TemporaryUserData = TemporaryUserData()
    @Published var messages: [ChatMessage] = []
    
    var userProfileManager: UserProfileManager
    
    init(userProfileManager: UserProfileManager) {
        self.userProfileManager = userProfileManager
    }
    
    enum ConversationState {
        case initial
        case askingHeight
        case askingWeight
        case askingAge
        case askingGender
        case askingActivityLevel
        case askingGoalType
        case askingDietaryPattern
        case confirmingGoals
        case completed
    }
    
    struct TemporaryUserData {
        var height: Double?
        var weight: Double?
        var age: Int?
        var gender: String?
        var activityLevel: ActivityLevel?
        var goalType: NutritionGoals.GoalType?
        var dietaryPattern: NutritionGoals.DietaryPattern?
    }
    
    // Start or continue the conversation based on current state
    func continueConversation() {
        switch conversationState {
        case .initial:
            addAssistantMessage("Let's set up your nutrition goals. This will help me personalize your meal plans. First, what's your height? (You can tell me in feet/inches or centimeters)")
            conversationState = .askingHeight
            
        case .askingHeight:
            if temporaryUserData.height != nil {
                addAssistantMessage("Great! And what's your current weight? (You can tell me in pounds or kilograms)")
                conversationState = .askingWeight
            }
            
        case .askingWeight:
            if temporaryUserData.weight != nil {
                addAssistantMessage("Thanks! What's your age?")
                conversationState = .askingAge
            }
            
        case .askingAge:
            if temporaryUserData.age != nil {
                addAssistantMessage("And how would you describe your gender? This helps me calculate your baseline needs more accurately.")
                conversationState = .askingGender
            }
            
        case .askingGender:
            if temporaryUserData.gender != nil {
                addAssistantMessage("How would you describe your activity level?")
                addActivityLevelOptions()
                conversationState = .askingActivityLevel
            }
            
        case .askingActivityLevel:
            if temporaryUserData.activityLevel != nil {
                addAssistantMessage("What's your main nutrition goal?")
                addGoalTypeOptions()
                conversationState = .askingGoalType
            }
            
        case .askingGoalType:
            if temporaryUserData.goalType != nil {
                addAssistantMessage("Do you follow a specific dietary pattern?")
                addDietaryPatternOptions()
                conversationState = .askingDietaryPattern
            }
            
        case .askingDietaryPattern:
            if temporaryUserData.dietaryPattern != nil {
                // Calculate preliminary goals and show summary
                calculateAndDisplayGoals()
                conversationState = .confirmingGoals
            }
            
        case .confirmingGoals:
            // Finalized in response to user confirmation
            addAssistantMessage("Perfect! I've saved your nutrition goals. I'll use these to personalize your meal plans. You can always update them by saying \"update my goals\" any time.")
            saveGoalsToUserProfile()
            conversationState = .completed
            
        case .completed:
            // Can restart conversation if needed
            break
        }
    }
    
    // Process user input based on current state
    func processUserInput(_ text: String) {
        addUserMessage(text)
        
        switch conversationState {
        case .initial:
            continueConversation()
            
        case .askingHeight:
            parseHeight(from: text)
            continueConversation()
            
        case .askingWeight:
            parseWeight(from: text)
            continueConversation()
            
        case .askingAge:
            parseAge(from: text)
            continueConversation()
            
        case .askingGender:
            temporaryUserData.gender = text
            continueConversation()
            
        case .askingActivityLevel:
            // Check if text matches one of the activity levels
            if let activityLevel = ActivityLevel.allCases.first(where: { $0.rawValue.lowercased().contains(text.lowercased()) }) {
                temporaryUserData.activityLevel = activityLevel
            } else {
                addAssistantMessage("I didn't quite catch that. Please select one of the activity levels from the options.")
                addActivityLevelOptions()
                return
            }
            continueConversation()
            
        case .askingGoalType:
            // Check if text matches one of the goal types
            if let goalType = NutritionGoals.GoalType.allCases.first(where: { $0.rawValue.lowercased().contains(text.lowercased()) }) {
                temporaryUserData.goalType = goalType
            } else {
                addAssistantMessage("I didn't quite understand that. Please select one of the goal types from the options.")
                addGoalTypeOptions()
                return
            }
            continueConversation()
            
        case .askingDietaryPattern:
            // Check if text matches one of the dietary patterns
            if let pattern = NutritionGoals.DietaryPattern.allCases.first(where: { $0.rawValue.lowercased().contains(text.lowercased()) }) {
                temporaryUserData.dietaryPattern = pattern
            } else {
                addAssistantMessage("I didn't catch that. Please select one of the dietary patterns from the options.")
                addDietaryPatternOptions()
                return
            }
            continueConversation()
            
        case .confirmingGoals:
            if text.lowercased().contains("yes") || text.lowercased().contains("confirm") || text.lowercased().contains("looks good") {
                continueConversation()
            } else if text.lowercased().contains("no") || text.lowercased().contains("change") || text.lowercased().contains("adjust") {
                // Offer options to adjust
                addAssistantMessage("What would you like to adjust?")
                addAdjustmentOptions()
            } else {
                addAssistantMessage("Do you want to confirm these nutrition goals? Say 'yes' to confirm or tell me what you'd like to adjust.")
            }
            
        case .completed:
            // If user wants to restart
            if text.lowercased().contains("restart") || text.lowercased().contains("new goals") {
                resetConversation()
            }
        }
    }
    
    // MARK: - UI Helper Functions
    
    private func addUserMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: true)
        messages.append(message)
    }
    
    private func addAssistantMessage(_ text: String) {
        let message = ChatMessage(text: text, isUser: false)
        messages.append(message)
    }
    
    private func addActivityLevelOptions() {
        var optionText = ""
        for level in ActivityLevel.allCases {
            optionText += "• \(level.rawValue)\n"
        }
        addAssistantMessage(optionText)
    }
    
    private func addGoalTypeOptions() {
        var optionText = ""
        for type in NutritionGoals.GoalType.allCases {
            optionText += "• \(type.rawValue): \(type.description)\n"
        }
        addAssistantMessage(optionText)
    }
    
    private func addDietaryPatternOptions() {
        var optionText = ""
        for pattern in NutritionGoals.DietaryPattern.allCases {
            optionText += "• \(pattern.rawValue)\n"
        }
        addAssistantMessage(optionText)
    }
    
    private func addAdjustmentOptions() {
        let message = ChatMessage(
            text: "Choose what to adjust",
            isUser: false,
            type: .macroSuggestion,
            associatedMeal: nil
        )
        messages.append(message)
    }
    
    private func calculateAndDisplayGoals() {
        guard let height = temporaryUserData.height,
              let weight = temporaryUserData.weight,
              let age = temporaryUserData.age,
              let gender = temporaryUserData.gender,
              let activityLevel = temporaryUserData.activityLevel,
              let goalType = temporaryUserData.goalType,
              let dietaryPattern = temporaryUserData.dietaryPattern else {
            addAssistantMessage("I'm missing some information to calculate your goals.")
            return
        }
        
        let goals = NutritionGoals.createDefault(
            weight: weight,
            heightCm: height,
            age: age,
            gender: gender,
            activityLevel: activityLevel,
            goalType: goalType,
            dietaryPattern: dietaryPattern
        )
        
        // Create a summary message
        let summaryText = """
        Based on your information, here's what I recommend:
        
        Daily Calories: \(goals.calorieGoal)
        Protein: \(Int(goals.macros.protein))g (\(Int(goals.targetProteinPerKg * weight))g)
        Carbs: \(Int(goals.macros.carbs))g
        Fat: \(Int(goals.macros.fat))g
        
        This is optimized for \(goalType.rawValue) with a \(dietaryPattern.rawValue) approach.
        
        Does this look good to you?
        """
        
        addAssistantMessage(summaryText)
    }
    
    private func saveGoalsToUserProfile() {
        guard let weight = temporaryUserData.weight,
              let height = temporaryUserData.height,
              let age = temporaryUserData.age,
              let gender = temporaryUserData.gender,
              let activityLevel = temporaryUserData.activityLevel,
              let goalType = temporaryUserData.goalType,
              let dietaryPattern = temporaryUserData.dietaryPattern else {
            return
        }
        
        userProfileManager.updateUserMetrics(
            weight: weight,
            heightCm: height,
            age: age,
            activityLevel: activityLevel
        )
        
        userProfileManager.userProfile.gender = gender
        userProfileManager.updateNutritionGoals(
            goalType: goalType,
            dietaryPattern: dietaryPattern
        )
    }
    
    // MARK: - Helper Methods
    
    private func parseHeight(from text: String) {
        // First check for cm
        if let cmMatch = text.range(of: #"\d+(\.\d+)?\s*cm"#, options: .regularExpression) {
            let cmText = text[cmMatch].replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            if let cm = Double(cmText) {
                temporaryUserData.height = cm
                return
            }
        }
        
        // Check for feet and inches format (e.g., "5'10" or "5 feet 10 inches")
        let feetInchesPattern = #"(\d+)[\s']*(?:feet|foot|ft)?[\s\"]*(?:and)?[\s\"]*(\d+)?\s*(?:inches|inch|in|\")?|(\d+)[\s']*(?:feet|foot|ft)"#
        if let feetInchesMatch = text.range(of: feetInchesPattern, options: .regularExpression) {
            let matchText = String(text[feetInchesMatch])
            
            // Extract feet
            if let feetMatch = matchText.range(of: #"(\d+)"#, options: .regularExpression) {
                let feetText = String(matchText[feetMatch])
                if let feet = Double(feetText) {
                    // Extract inches if present
                    var inches: Double = 0
                    if let inchesMatch = matchText.range(of: #"[\s']+(\d+)"#, options: .regularExpression) {
                        let inchesText = matchText[inchesMatch].replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                        inches = Double(inchesText) ?? 0
                    }
                    
                    // Convert to cm
                    temporaryUserData.height = (feet * 30.48) + (inches * 2.54)
                    return
                }
            }
        }
        
        // If all parsing fails, prompt again
        addAssistantMessage("I'm having trouble understanding your height. Please try again using centimeters (e.g., '170 cm') or feet and inches (e.g., '5'10\" or '5 feet 10 inches').")
    }
    
    private func parseWeight(from text: String) {
        // Check for kg
        if let kgMatch = text.range(of: #"\d+(\.\d+)?\s*(?:kg|kilograms|kilos)"#, options: .regularExpression) {
            let kgText = text[kgMatch].replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            if let kg = Double(kgText) {
                temporaryUserData.weight = kg
                return
            }
        }
        
        // Check for pounds/lbs
        if let lbsMatch = text.range(of: #"\d+(\.\d+)?\s*(?:pounds|pound|lbs|lb)"#, options: .regularExpression) {
            let lbsText = text[lbsMatch].replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
            if let lbs = Double(lbsText) {
                // Convert to kg
                temporaryUserData.weight = lbs * 0.45359237
                return
            }
        }
        
        // Just a number - assume kg if less than 200, otherwise pounds
        if let numberMatch = text.range(of: #"\d+(\.\d+)?"#, options: .regularExpression) {
            let numberText = text[numberMatch]
            if let number = Double(numberText) {
                if number < 200 {
                    // Likely kg
                    temporaryUserData.weight = number
                } else {
                    // Likely pounds
                    temporaryUserData.weight = number * 0.45359237
                }
                return
            }
        }
        
        // If all parsing fails, prompt again
        addAssistantMessage("I'm having trouble understanding your weight. Please try again using kilograms (e.g., '70 kg') or pounds (e.g., '154 lbs').")
    }
    
    private func parseAge(from text: String) {
        if let ageMatch = text.range(of: #"\d+"#, options: .regularExpression) {
            let ageText = text[ageMatch]
            if let age = Int(ageText), age > 0 && age < 120 {
                temporaryUserData.age = age
                return
            }
        }
        
        // If parsing fails, prompt again
        addAssistantMessage("I'm having trouble understanding your age. Please provide just the number (e.g., '35').")
    }
    
    private func resetConversation() {
        conversationState = .initial
        temporaryUserData = TemporaryUserData()
        addAssistantMessage("Let's start over with setting your nutrition goals.")
        continueConversation()
    }
}
