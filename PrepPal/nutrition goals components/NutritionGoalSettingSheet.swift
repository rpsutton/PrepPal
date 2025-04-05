import SwiftUI

// MARK: - Nutrition Goal Setting Sheet
struct NutritionGoalSettingSheet: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @Binding var isPresented: Bool
    @State var temporaryUserData = TemporaryUserData()
    @State var currentStep: GoalSettingStep = .welcome
    @State var showingCustomization = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            sheetHeader
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Step content
                    stepContent
                    
                    // Navigation buttons
                    navigationButtons
                }
                .padding()
            }
        }
        .background(PrepPalTheme.Colors.background)
        .onAppear {
            // Initialize with existing data if available
            if let goals = userProfileManager.userProfile.nutritionGoals {
                temporaryUserData.goalType = goals.goalType
                temporaryUserData.dietaryPattern = goals.dietaryPattern
                temporaryUserData.weight = userProfileManager.userProfile.weight
                temporaryUserData.heightCm = userProfileManager.userProfile.heightCm
                temporaryUserData.age = userProfileManager.userProfile.age
                temporaryUserData.gender = userProfileManager.userProfile.gender
                temporaryUserData.activityLevel = userProfileManager.userProfile.activityLevel
            }
        }
    }
    
    // MARK: - Sheet Header
    var sheetHeader: some View {
        ZStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                }
                Spacer()
            }
            
            Text("Nutrition Goals")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    // MARK: - Step Content
    var stepContent: some View {
        VStack(spacing: 20) {
            switch currentStep {
            case .welcome:
                welcomeStep
            case .basicInfo:
                basicInfoStep
            case .goalType:
                goalTypeStep
            case .dietaryPattern:
                dietaryPatternStep
            case .review:
                reviewStep
            }
        }
    }
    
    // MARK: - Navigation Buttons
    var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep != .welcome {
                // Back button
                Button(action: {
                    moveToPreviousStep()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(PrepPalTheme.Colors.gray100)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
            
            // Continue button
            Button(action: {
                if currentStep == .review {
                    // Save goals and dismiss sheet
                    if let goals = calculateGoals() {
                        saveGoals(goals)
                        isPresented = false
                    }
                } else {
                    moveToNextStep()
                }
            }) {
                Text(currentStep == .review ? "Save Goals" : "Continue")
                    .font(PrepPalTheme.Typography.bodyRegular.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(PrepPalTheme.Colors.primary)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
            }
            .disabled(isNextButtonDisabled)
        }
    }
    
    // MARK: - Helper Methods
    
    // Calculate goals based on user inputs
    func calculateGoals() -> NutritionGoals? {
        guard let weight = temporaryUserData.weight,
              let heightCm = temporaryUserData.heightCm,
              let age = temporaryUserData.age,
              let gender = temporaryUserData.gender,
              let activityLevel = temporaryUserData.activityLevel,
              let goalType = temporaryUserData.goalType,
              let dietaryPattern = temporaryUserData.dietaryPattern else {
            return nil
        }
        
        return NutritionGoals.createDefault(
            weight: weight,
            heightCm: heightCm,
            age: age,
            gender: gender,
            activityLevel: activityLevel,
            goalType: goalType,
            dietaryPattern: dietaryPattern
        )
    }
    
    // Save goals to user profile
    func saveGoals(_ goals: NutritionGoals) {
        userProfileManager.updateUserMetrics(
            weight: temporaryUserData.weight,
            heightCm: temporaryUserData.heightCm,
            age: temporaryUserData.age,
            activityLevel: temporaryUserData.activityLevel
        )
        
        if let gender = temporaryUserData.gender {
            userProfileManager.userProfile.gender = gender
        }
        
        userProfileManager.updateNutritionGoals(
            goalType: goals.goalType,
            dietaryPattern: goals.dietaryPattern
        )
    }
    
    // Navigation
    func moveToNextStep() {
        withAnimation {
            switch currentStep {
            case .welcome:
                currentStep = .basicInfo
            case .basicInfo:
                currentStep = .goalType
            case .goalType:
                currentStep = .dietaryPattern
            case .dietaryPattern:
                currentStep = .review
            case .review:
                break
            }
        }
    }
    
    func moveToPreviousStep() {
        withAnimation {
            switch currentStep {
            case .welcome:
                break
            case .basicInfo:
                currentStep = .welcome
            case .goalType:
                currentStep = .basicInfo
            case .dietaryPattern:
                currentStep = .goalType
            case .review:
                currentStep = .dietaryPattern
            }
        }
    }
    
    // Validation for next button
    var isNextButtonDisabled: Bool {
        switch currentStep {
        case .welcome:
            return false
        case .basicInfo:
            return temporaryUserData.weight == nil ||
                   temporaryUserData.heightCm == nil ||
                   temporaryUserData.age == nil ||
                   temporaryUserData.gender == nil ||
                   temporaryUserData.activityLevel == nil
        case .goalType:
            return temporaryUserData.goalType == nil
        case .dietaryPattern:
            return temporaryUserData.dietaryPattern == nil
        case .review:
            return calculateGoals() == nil
        }
    }
    
}
