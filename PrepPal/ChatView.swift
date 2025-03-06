import SwiftUI

struct ChatView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State var messageText: String = ""
    @State var messages: [ChatMessage] = []
    @State var isShowingCamera: Bool = false
    @State var isShowingNutritionGoalSheet: Bool = false
    @State var isLoading: Bool = false
    @State var showNutritionTriggerHint: Bool = false
    
    // Add state variables for meal plans
    @State var showMealPlanSheet: Bool = false
    @State var showMealDetail: Bool = false
    @State var selectedMeal: Meal? = nil
    @State var weeklyMealPlan: WeeklyMealPlan = WeeklyMealPlan.createSampleData()
    
    // Quick action suggestions
    private let quickActions = [
        "Set nutrition goals",
        "Meal prep ideas",
        "Healthy snacks"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            chatHeader
            
            // Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Quick action suggestion at the top
                        if messages.isEmpty {
                            welcomeMessage
                        }
                        
                        // Messages
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        // Loading indicator
                        if isLoading {
                            HStack {
                                Spacer(minLength: 60)
                                TypingIndicator()
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Show hint for setting nutrition goals if appropriate
            if showNutritionTriggerHint {
                nutritionGoalHint
            }
            
            // Input bar
            ChatInputBar(
                messageText: $messageText,
                onSend: sendMessage,
                onCamera: { isShowingCamera = true }
            )
            .withNutritionGoalQuickActions(onSelected: handleQuickAction)
        }
        .sheet(isPresented: $isShowingNutritionGoalSheet) {
            NutritionGoalSettingSheet(isPresented: $isShowingNutritionGoalSheet)
                .environmentObject(userProfileManager)
        }
        .sheet(isPresented: $isShowingCamera) {
            Text("Camera View Placeholder")
                .font(PrepPalTheme.Typography.bodyRegular)
                .padding()
        }
        .onAppear {
            addWelcomeMessage()
            checkForNutritionGoals()
        }
    }
    
    // MARK: - UI Components
    
    private var chatHeader: some View {
        HStack {
            Text("PrepPal")
                .font(PrepPalTheme.Typography.headerLarge)
                .foregroundColor(PrepPalTheme.Colors.primary)
            
            Spacer()
            
            // User profile or settings button
            Button(action: {
                // Open user profile or settings
            }) {
                Image(systemName: "person.circle")
                    .font(.system(size: 24))
                    .foregroundColor(PrepPalTheme.Colors.primary)
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Text("Welcome to PrepPal! 👋")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
            
            Text("I'm your personal nutrition and meal prep assistant. How can I help you today?")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                ForEach(quickActions, id: \.self) { action in
                    Button(action: {
                        handleQuickAction(action)
                    }) {
                        Text(action)
                            .font(PrepPalTheme.Typography.bodyRegular)
                            .foregroundColor(PrepPalTheme.Colors.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                    .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                            )
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
    }
    
    private var nutritionGoalHint: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(PrepPalTheme.Colors.primary)
                    .font(.system(size: 14))
            }
            
            Text("Setting your nutrition goals helps me create personalized meal plans.")
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
            
            Button(action: {
                isShowingNutritionGoalSheet = true
            }) {
                Text("Set Goals")
                    .font(PrepPalTheme.Typography.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PrepPalTheme.Colors.primary)
                    .cornerRadius(12)
            }
        }
        .padding(12)
        .background(PrepPalTheme.Colors.primary.opacity(0.05))
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    func addWelcomeMessage() {
        if messages.isEmpty {
            let welcomeMessage = ChatMessage(
                text: "Hi there! I'm PrepPal, your nutrition and meal planning assistant. How can I help you today?",
                isUser: false
            )
            messages.append(welcomeMessage)
        }
    }
    
    func checkForNutritionGoals() {
        // Show nutrition goal hint if user doesn't have goals set
        if userProfileManager.userProfile.nutritionGoals == nil {
            // Wait a moment before showing the hint to not overwhelm the user
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showNutritionTriggerHint = true
            }
        }
    }
    
    func handleQuickAction(_ action: String) {
        // Process the quick action
        if action.lowercased().contains("nutrition") || action.lowercased().contains("goals") {
            // Show nutrition goal setting sheet
            messageText = action
            sendMessage()
            
            // Add a small delay before showing the sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShowingNutritionGoalSheet = true
            }
        } else {
            // Handle other quick actions
            messageText = action
            sendMessage()
        }
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(text: messageText, isUser: true)
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
        } else {
            // Process through regular AI flow
            processWithAI(sentMessage)
        }
    }
    
    func isNutritionGoalMessage(_ message: String) -> Bool {
        let lowerMessage = message.lowercased()
        
        // Keywords related to nutrition goals
        let nutritionKeywords = ["nutrition", "macros", "calories", "protein", "carbs", "diet", "goals"]
        
        // Check if any keywords are present
        for keyword in nutritionKeywords {
            if lowerMessage.contains(keyword) && (lowerMessage.contains("set") || lowerMessage.contains("goals")) {
                return true
            }
        }
        
        return false
    }
    
    func handleNutritionGoalMessage(_ message: String) {
        // Add assistant response about nutrition goals
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let responseMessage = ChatMessage(
                text: "I'd be happy to help you set your nutrition goals! This will help me create personalized meal plans that align with your needs.",
                isUser: false
            )
            messages.append(responseMessage)
            
            // Add nutrition goal card message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let nutritionMessage = ChatMessage.createNutritionGoalMessage(
                    isUser: false,
                    type: userProfileManager.userProfile.nutritionGoals == nil
                        ? .nutritionGoalSetting
                        : .nutritionGoalUpdate
                )
                messages.append(nutritionMessage)
                
                isLoading = false
                
                // Show the nutrition goal sheet
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    isShowingNutritionGoalSheet = true
                }
            }
        }
    }
    
    func processWithAI(_ message: String) {
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // In a real implementation, this would call your Firebase function to Claude API
            let responseMessage = ChatMessage(
                text: "I'm processing your request about \"\(message)\". In a real implementation, this would use Claude AI via Firebase.",
                isUser: false
            )
            messages.append(responseMessage)
            isLoading = false
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(PrepPalTheme.Colors.gray400)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset(for: index))
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(PrepPalTheme.Colors.assistantMessage)
        .cornerRadius(12)
        .onAppear {
            animationOffset = 5
        }
    }
    
    private func animationOffset(for index: Int) -> CGFloat {
        if animationOffset == 0 {
            return 0
        } else {
            return -animationOffset
        }
    }
}

// MARK: - Preview
#Preview {
    ChatView()
        .environmentObject(UserProfileManager())
}
