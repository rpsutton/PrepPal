import SwiftUI
import FirebaseFunctions

struct ChatView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @State var messageText: String = ""
    @State var messages: [ChatMessage] = []
    @State var isShowingCamera: Bool = false
    @State var isShowingNutritionGoalSheet: Bool = false
    @State var isLoading: Bool = false
    @State var showNutritionTriggerHint: Bool = false
    
    @State var isShowingSettingsSheet: Bool = false
    @State var isShowingMealPlanTimeline: Bool = false
    
    @State var showMealPlanSheet: Bool = false
    @State var showMealDetail: Bool = false
    @State var selectedMeal: Meal? = nil
    @State var weeklyMealPlan: WeeklyMealPlan = WeeklyMealPlan.createSampleData()
    
    @State private var activeCookingSession: Meal? = nil
    
    @StateObject private var contextManager = ContextManager()
    @StateObject private var mealPlanStorage = MealPlanStorage()
    @StateObject private var preferenceManager: PreferenceManager
    @StateObject private var llmService = LLMService()
    
    init() {
        _preferenceManager = StateObject(wrappedValue: PreferenceManager(userId: UserProfileManager().userProfile.id))
    }
    
    @State private var quickActions = [
        "Set nutrition goals",
        "Meal prep ideas",
        "Healthy snacks"
    ]

    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if userProfileManager.userProfile.nutritionGoals != nil {
                            Spacer()
                                .frame(height: 80)
                        }
                        
                        if messages.isEmpty {
                            welcomeMessage
                        }
                        
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
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
                
                ChatCombinedHeaderView(
                    onSettingsPressed: { isShowingSettingsSheet = true },
                    onCalendarPressed: { isShowingMealPlanTimeline = true },
                    goals: userProfileManager.userProfile.nutritionGoals
                )
                
                VStack {
                    Spacer()
                    if showNutritionTriggerHint {
                        nutritionGoalHint
                    }
                    
                    QuickActions(
                        actions: quickActions,
                        onSelect: handleQuickAction
                    )
                    
                    ChatInputBar(
                        messageText: $messageText,
                        onSend: sendMessage,
                        onCamera: { isShowingCamera = true }
                    )
                }
            }
            .sheet(isPresented: $isShowingSettingsSheet) {
                NavigationView {
                    Text("Settings")
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                }
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
            .alert(isPresented: $showError) {
                errorAlert
            }
            .overlay(loadingOverlay)
        }
        .onAppear {
            addWelcomeMessage()
            checkForNutritionGoals()
        }
    }
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            Text("Welcome to PrepPal! ")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 16)
            
            Text("I'm your personal nutrition and meal prep assistant. How can I help you today?")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(PrepPalTheme.Colors.gray400)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
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
    
    private var errorAlert: Alert {
        Alert(
            title: Text("Error"),
            message: Text(errorMessage),
            dismissButton: .default(Text("OK"))
        )
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                            .scaleEffect(1.5)
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            }
        }
    }
    
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
        if userProfileManager.userProfile.nutritionGoals == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showNutritionTriggerHint = true
            }
        }
    }
    
    func handleQuickAction(_ action: String) {
        if action.lowercased().contains("nutrition") || action.lowercased().contains("goals") {
            messageText = action
            sendMessage()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isShowingNutritionGoalSheet = true
            }
        } else {
            messageText = action
            sendMessage()
        }
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: messageText,
            role: .user,
            messageType: .text,
            contextualRelevance: .medium
        )
        contextManager.currentSession.addMessage(userMessage)
        
        let sentMessage = messageText
        messageText = ""
        
        isLoading = true
        
        Task {
            do {
                let response = try await processWithLLM(sentMessage)
                await MainActor.run {
                    handleLLMResponse(response)
                    isLoading = false
                }
            } catch {
                print("Error processing message: \(error)")
                await MainActor.run {
                    isLoading = false
                    showError = true
                    errorMessage = "Failed to process message"
                }
            }
        }
    }
    
    private func processWithLLM(_ message: String) async throws -> LLMResponse {
        let context = contextManager.currentSession.messages
            .filter { $0.contextualRelevance.rawValue >= ChatMessage.ContextRelevance.medium.rawValue }
        
        let enhancedContext = preferenceManager.enhanceContext(context)
        
        return try await llmService.processRequest(
            context,
            context: enhancedContext,
            userId: userProfileManager.userProfile.id
        )
    }
    
    private func handleLLMResponse(_ response: LLMResponse) {
        // Create message using the helper
        let assistantMessage = ChatMessage.createFromLLMResponse(response)
        contextManager.currentSession.addMessage(assistantMessage)
        
        // Handle side effects based on message type
        switch assistantMessage.messageType {
        case .mealPlan(let customView):
            switch customView {
            case .weeklyMealPlan(let plan):
                handleNewMealPlan(plan)
            case .recipe(let meal):
                handleNewRecipe(meal)
            default:
                break
            }
        case .recipe:
            if let meal = assistantMessage.associatedData?.mealPlan {
                handleNewRecipe(meal)
            }
        case .nutritionGoal:
            if let goals = assistantMessage.associatedData?.nutritionGoals {
               
            }
        default:
            break
        }
    }
    
    private func handleNewMealPlan(_ plan: WeeklyMealPlan) {
        Task {
            do {
                // Save to storage
                try await mealPlanStorage.saveMealPlanToCloud(plan, userId: userProfileManager.userProfile.id)
                
                // Update UI
                await MainActor.run {
                    weeklyMealPlan = plan
                    showMealPlanSheet = true
                }
                
                // Record preferences
                for dailyPlan in plan.dailyPlans {
                    for meal in dailyPlan.meals {
                        preferenceManager.recordMealInteraction(
                            meal: meal,
                            score: 0.5,
                            context: "Generated meal plan"
                        )
                    }
                }
            } catch {
                print("Error saving meal plan: \(error)")
                await MainActor.run {
                    showError = true
                    errorMessage = "Failed to save meal plan"
                }
            }
        }
    }
    
    private func handleNewRecipe(_ meal: Meal) {
        selectedMeal = meal
        showMealDetail = true
    }
}

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

#Preview {
    ChatView()
        .environmentObject(UserProfileManager())
}
