import Foundation
import FirebaseFunctions

// MARK: - Chat Message
struct ChatMessage: Codable, Identifiable {
    let id: UUID
    let content: String
    let role: MessageRole
    let timestamp: Date
    let messageType: MessageType
    var contextualRelevance: ContextRelevance
    var associatedData: MessageAssociatedData?
    
    var isUser: Bool {
        role == .user
    }
    
    // MARK: - API Conversion
    var toLLMMessage: LLMRequestMessage {
        LLMRequestMessage(role: role.rawValue, content: content)
    }
    
    // MARK: - Message Role
    enum MessageRole: String, Codable {
        case user
        case assistant
        case system
    }
    
    // MARK: - Message Type
    enum MessageType: Codable {
        case text
        case image
        case mealPlan(CustomViewType)
        case recipe
        case nutritionGoal
        case preference
        case macroSuggestion
        case recipeSuggestion
        
        enum CustomViewType: Codable {
            case dailyMealPlan(dailyPlan: DailyMealPlan)
            case weeklyMealPlan(weeklyPlan: WeeklyMealPlan)
            case macroProgress(dailyPlan: DailyMealPlan)
            case recipe(meal: Meal)
            
            private enum CodingKeys: String, CodingKey {
                case type, dailyPlan, weeklyPlan, meal
            }
            
            private enum TypeCoding: String, Codable {
                case dailyMealPlan, weeklyMealPlan, macroProgress, recipe
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                switch self {
                case .dailyMealPlan(let plan):
                    try container.encode(TypeCoding.dailyMealPlan, forKey: .type)
                    try container.encode(plan, forKey: .dailyPlan)
                case .weeklyMealPlan(let plan):
                    try container.encode(TypeCoding.weeklyMealPlan, forKey: .type)
                    try container.encode(plan, forKey: .weeklyPlan)
                case .macroProgress(let plan):
                    try container.encode(TypeCoding.macroProgress, forKey: .type)
                    try container.encode(plan, forKey: .dailyPlan)
                case .recipe(let meal):
                    try container.encode(TypeCoding.recipe, forKey: .type)
                    try container.encode(meal, forKey: .meal)
                }
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let type = try container.decode(TypeCoding.self, forKey: .type)
                
                switch type {
                case .dailyMealPlan:
                    let plan = try container.decode(DailyMealPlan.self, forKey: .dailyPlan)
                    self = .dailyMealPlan(dailyPlan: plan)
                case .weeklyMealPlan:
                    let plan = try container.decode(WeeklyMealPlan.self, forKey: .weeklyPlan)
                    self = .weeklyMealPlan(weeklyPlan: plan)
                case .macroProgress:
                    let plan = try container.decode(DailyMealPlan.self, forKey: .dailyPlan)
                    self = .macroProgress(dailyPlan: plan)
                case .recipe:
                    let meal = try container.decode(Meal.self, forKey: .meal)
                    self = .recipe(meal: meal)
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case type, customView
        }
        
        private enum TypeCoding: String, Codable {
            case text, image, mealPlan, recipe, nutritionGoal, preference, macroSuggestion, recipeSuggestion
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .text:
                try container.encode(TypeCoding.text, forKey: .type)
            case .image:
                try container.encode(TypeCoding.image, forKey: .type)
            case .mealPlan(let customView):
                try container.encode(TypeCoding.mealPlan, forKey: .type)
                try container.encode(customView, forKey: .customView)
            case .recipe:
                try container.encode(TypeCoding.recipe, forKey: .type)
            case .nutritionGoal:
                try container.encode(TypeCoding.nutritionGoal, forKey: .type)
            case .preference:
                try container.encode(TypeCoding.preference, forKey: .type)
            case .macroSuggestion:
                try container.encode(TypeCoding.macroSuggestion, forKey: .type)
            case .recipeSuggestion:
                try container.encode(TypeCoding.recipeSuggestion, forKey: .type)
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(TypeCoding.self, forKey: .type)
            
            switch type {
            case .text:
                self = .text
            case .image:
                self = .image
            case .mealPlan:
                let customView = try container.decode(CustomViewType.self, forKey: .customView)
                self = .mealPlan(customView)
            case .recipe:
                self = .recipe
            case .nutritionGoal:
                self = .nutritionGoal
            case .preference:
                self = .preference
            case .macroSuggestion:
                self = .macroSuggestion
            case .recipeSuggestion:
                self = .recipeSuggestion
            }
        }
    }
    
    // MARK: - Context Relevance
    enum ContextRelevance: Int, Codable {
        case critical = 100    // Dietary restrictions, allergies
        case high = 75        // Current conversation focus
        case medium = 50      // Recent context
        case low = 25         // General chat
        case archivable = 0   // Can be summarized/removed
    }
    
    // MARK: - Initializers
    init(id: UUID = UUID(),
         content: String,
         role: MessageRole,
         messageType: MessageType = .text,
         contextualRelevance: ContextRelevance = .medium,
         associatedData: MessageAssociatedData? = nil) {
        self.id = id
        self.content = content
        self.role = role
        self.timestamp = Date()
        self.messageType = messageType
        self.contextualRelevance = contextualRelevance
        self.associatedData = associatedData
    }
    
    // Convenience initializer for UI-focused creation
    init(text: String, isUser: Bool, type: MessageType = .text, associatedMeal: Meal? = nil) {
        self.id = UUID()
        self.content = text
        self.role = isUser ? .user : .assistant
        self.timestamp = Date()
        self.messageType = type
        self.contextualRelevance = isUser ? .medium : .high
        
        if let meal = associatedMeal {
            self.associatedData = MessageAssociatedData(mealPlan: meal)
        }
    }
    
    // MARK: - LLM Response Processing
    static func createFromLLMResponse(_ response: LLMResponse) -> ChatMessage {
        // Determine message type based on response content
        let messageType: MessageType
        var associatedData: MessageAssociatedData?
        
        if let mealPlan = response.mealPlan {
            messageType = .mealPlan(.weeklyMealPlan(weeklyPlan: mealPlan))
            associatedData = MessageAssociatedData(mealPlan: mealPlan.dailyPlans.first?.meals.first)
        } else if let recipe = response.recipe {
            messageType = .recipe
            associatedData = MessageAssociatedData(mealPlan: recipe)
        } else if let goals = response.nutritionGoals {
            messageType = .nutritionGoal
            associatedData = MessageAssociatedData(nutritionGoals: goals)
        } else {
            messageType = .text
        }
        
        return ChatMessage(
            content: response.content,
            role: .assistant,
            messageType: messageType,
            contextualRelevance: .high,
            associatedData: associatedData
        )
    }
}

// MARK: - LLM Communication
struct LLMRequestMessage: Codable {
    let role: String
    let content: String
}

struct LLMRequest: Codable {
    let messages: [LLMRequestMessage]
    let enhancedContext: String
    let userId: String
    var temperature: Double = 0.7
    var maxTokens: Int = 1000
}

struct LLMResponse: Codable {
    let content: String
    var mealPlan: WeeklyMealPlan?
    var recipe: Meal?
    var nutritionGoals: NutritionGoals?
    var contextSummary: String?
}

// MARK: - LLM Service
@MainActor
class LLMService: ObservableObject {
    private let functions = Functions.functions()
    @Published private(set) var isProcessing = false
    @Published private(set) var lastError: Error?
    
    enum ServiceError: Error, LocalizedError {
        case functionNotConfigured
        case invalidResponse
        case processingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .functionNotConfigured:
                return "Firebase Functions not configured. Check your GoogleService-Info.plist"
            case .invalidResponse:
                return "Invalid response from LLM service"
            case .processingFailed(let error):
                return "Processing failed: \(error.localizedDescription)"
            }
        }
    }
    
    func processRequest(_ messages: [ChatMessage], context: String, userId: String) async throws -> LLMResponse {
        guard let _ = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            throw ServiceError.functionNotConfigured
        }
        
        isProcessing = true
        lastError = nil
        
        do {
            let request = LLMRequest(
                messages: messages.map(\.toLLMMessage),
                enhancedContext: context,
                userId: userId
            )
            
            let callable = functions.httpsCallable("processLLMRequest")
            let result = try await callable.call(request)
            
            guard let data = result.data as? [String: Any] else {
                throw ServiceError.invalidResponse
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            isProcessing = false
            return try JSONDecoder().decode(LLMResponse.self, from: jsonData)
        } catch {
            isProcessing = false
            lastError = error
            throw ServiceError.processingFailed(error);
        }
    }
}

// MARK: - Errors
enum LLMError: Error {
    case invalidResponse
    case processingFailed(Error)
}

// MARK: - Message Associated Data
struct MessageAssociatedData: Codable {
    var nutritionGoals: NutritionGoals?
    var mealPlan: Meal?
    var userPreferences: [String: String]?
    
    private enum CodingKeys: String, CodingKey {
        case nutritionGoals, mealPlan, userPreferences
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let goals = nutritionGoals {
            try container.encode(goals, forKey: .nutritionGoals)
        }
        if let meal = mealPlan {
            try container.encode(meal, forKey: .mealPlan)
        }
        if let prefs = userPreferences {
            try container.encode(prefs, forKey: .userPreferences)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        nutritionGoals = try container.decodeIfPresent(NutritionGoals.self, forKey: .nutritionGoals)
        mealPlan = try container.decodeIfPresent(Meal.self, forKey: .mealPlan)
        userPreferences = try container.decodeIfPresent([String: String].self, forKey: .userPreferences)
    }
    
    init(nutritionGoals: NutritionGoals? = nil, mealPlan: Meal? = nil, userPreferences: [String: String]? = nil) {
        self.nutritionGoals = nutritionGoals
        self.mealPlan = mealPlan
        self.userPreferences = userPreferences
    }
}

// MARK: - Chat Session
class ChatSession: ObservableObject {
    let id: UUID
    let startTime: Date
    @Published var messages: [ChatMessage]
    var contextSummary: String?
    var tokenCount: Int
    let maxTokens: Int = 4000  // Adjust based on model
    
    init(id: UUID = UUID(), messages: [ChatMessage] = []) {
        self.id = id
        self.startTime = Date()
        self.messages = messages
        self.tokenCount = 0
    }
    
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
        updateTokenCount()
        if tokenCount > maxTokens {
            pruneContext()
        }
    }
    
    private func updateTokenCount() {
        // Implement token counting logic
        // This is a simplified version
        tokenCount = messages.reduce(0) { count, message in
            count + (message.content.split(separator: " ").count * 2)
        }
    }
    
    private func pruneContext() {
        // Start with lowest relevance messages
        let sortedMessages = messages.sorted { $0.contextualRelevance.rawValue < $1.contextualRelevance.rawValue }
        
        // Keep removing messages until under token limit
        var messagesToKeep = sortedMessages
        while tokenCount > maxTokens && !messagesToKeep.isEmpty {
            if let message = messagesToKeep.first, message.contextualRelevance != .critical {
                messagesToKeep.removeFirst()
                updateTokenCount()
            } else {
                break
            }
        }
        
        messages = messagesToKeep
    }
}

// MARK: - Context Manager
class ContextManager: ObservableObject {
    @Published var currentSession: ChatSession
    private var archivedSessions: [ChatSession]
    private var criticalContext: [String: Any]
    
    init() {
        self.currentSession = ChatSession()
        self.archivedSessions = []
        self.criticalContext = [:]
    }
    
    func startNewSession() {
        // Archive current session
        archivedSessions.append(currentSession)
        
        // Create new session with critical context
        let newSession = ChatSession()
        if let criticalInfo = generateCriticalContext() {
            newSession.addMessage(ChatMessage(
                id: UUID(),
                content: criticalInfo,
                role: .system,
                messageType: .text,
                contextualRelevance: .critical
            ))
        }
        
        currentSession = newSession
    }
    
    private func generateCriticalContext() -> String? {
        // Combine all critical information into a concise context
        var context: [String] = []
        
        if let dietaryRestrictions = criticalContext["dietaryRestrictions"] as? [String] {
            context.append("Dietary Restrictions: \(dietaryRestrictions.joined(separator: ", "))")
        }
        
        if let allergies = criticalContext["allergies"] as? [String] {
            context.append("Allergies: \(allergies.joined(separator: ", "))")
        }
        
        if let goals = criticalContext["nutritionGoals"] as? NutritionGoals {
            context.append("Goal: \(goals.goalType.rawValue)")
            context.append("Diet: \(goals.dietaryPattern.rawValue)")
        }
        
        return context.isEmpty ? nil : context.joined(separator: "\n")
    }
    
    func updateCriticalContext(_ key: String, value: Any) {
        criticalContext[key] = value
    }
    
    func searchPreviousContext(query: String) -> [ChatMessage] {
        // Search through archived sessions for relevant context
        return archivedSessions.flatMap { session in
            session.messages.filter { message in
                message.content.localizedCaseInsensitiveContains(query)
            }
        }
    }
}
