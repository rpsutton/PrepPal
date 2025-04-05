import Foundation
import FirebaseCore
import FirebaseFirestore

class MealPlanStorage: ObservableObject {
    private let db = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    // Published properties for UI updates
    @Published var currentMealPlan: WeeklyMealPlan?
    @Published var savedMealPlans: [WeeklyMealPlan] = []
    
    // Local storage keys
    private enum StorageKeys {
        static let currentPlan = "current_meal_plan"
        static let cachedPlans = "cached_meal_plans"
        static let lastSyncTime = "last_sync_time"
    }
    
    // MARK: - Firestore Operations
    
    func saveMealPlanToCloud(_ mealPlan: WeeklyMealPlan, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection("mealPlans").document()
        try docRef.setData(from: mealPlan)
    }
    
    func fetchMealPlansFromCloud(userId: String) async throws -> [WeeklyMealPlan] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("mealPlans")
            .order(by: "createdAt", descending: true)
            .limit(to: 10)
            .getDocuments()
        
        return try snapshot.documents.compactMap { doc in
            try doc.data(as: WeeklyMealPlan.self)
        }
    }
    
    // MARK: - Local Storage Operations
    
    func saveCurrentMealPlan(_ mealPlan: WeeklyMealPlan) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(mealPlan)
        
        // Save to UserDefaults for quick access
        userDefaults.set(data, forKey: StorageKeys.currentPlan)
        
        // Save to document directory for larger storage
        try saveMealPlanToFile(mealPlan)
        
        // Update published property
        DispatchQueue.main.async {
            self.currentMealPlan = mealPlan
        }
    }
    
    func loadCurrentMealPlan() throws -> WeeklyMealPlan? {
        // Try loading from UserDefaults first
        if let data = userDefaults.data(forKey: StorageKeys.currentPlan) {
            let decoder = JSONDecoder()
            return try decoder.decode(WeeklyMealPlan.self, from: data)
        }
        
        // Fall back to file storage
        return try loadMealPlanFromFile()
    }
    
    // MARK: - File Operations
    
    private func saveMealPlanToFile(_ mealPlan: WeeklyMealPlan) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(mealPlan)
        
        let url = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("current_meal_plan.json")
        
        try data.write(to: url)
    }
    
    private func loadMealPlanFromFile() throws -> WeeklyMealPlan? {
        let url = try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("current_meal_plan.json")
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(WeeklyMealPlan.self, from: data)
    }
    
    // MARK: - Sync Operations
    
    func syncMealPlans(userId: String) async throws {
        // Fetch from cloud
        let cloudPlans = try await fetchMealPlansFromCloud(userId: userId)
        
        // Update local cache
        try await MainActor.run {
            self.savedMealPlans = cloudPlans
            try? self.cacheMealPlans(cloudPlans)
        }
    }
    
    private func cacheMealPlans(_ plans: [WeeklyMealPlan]) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(plans)
        userDefaults.set(data, forKey: StorageKeys.cachedPlans)
        userDefaults.set(Date(), forKey: StorageKeys.lastSyncTime)
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        userDefaults.removeObject(forKey: StorageKeys.cachedPlans)
        userDefaults.removeObject(forKey: StorageKeys.lastSyncTime)
    }
    
    func shouldSync() -> Bool {
        guard let lastSync = userDefaults.object(forKey: StorageKeys.lastSyncTime) as? Date else {
            return true
        }
        
        // Sync if last sync was more than 1 hour ago
        return Date().timeIntervalSince(lastSync) > 3600
    }
}
