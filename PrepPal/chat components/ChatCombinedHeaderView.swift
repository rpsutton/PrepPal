import SwiftUI

struct ChatCombinedHeaderView: View {
    let onSettingsPressed: () -> Void
    let onCalendarPressed: () -> Void
    let goals: NutritionGoals?
    @State private var isExpanded = false
    @State private var headerHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Main header HStack
            HStack(spacing: 10) {
                // Left side controls
                HStack(spacing: 20) {
                    Button(action: onSettingsPressed) {
                        Image(systemName: "person")
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    NavigationLink(destination: MealPlanTimelineView(
                        weeklyPlan: WeeklyMealPlan.createSampleData()
                    )) {
                        Image(systemName: "fork.knife")
                            .foregroundColor(PrepPalTheme.Colors.gray600)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                
                Spacer()
                
                if let goals = goals {
                    // Right side macros and calories
                    HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                        // Calorie counter
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(Int(goals.macros.calories))")
                                .font(PrepPalTheme.Typography.bodyRegular.bold())
                                .foregroundColor(PrepPalTheme.Colors.gray600)
                            
                            Text("/ \(goals.calorieGoal)")
                                .font(PrepPalTheme.Typography.bodyRegular)
                                .foregroundColor(PrepPalTheme.Colors.gray400)
                        }
                        
                        // Macro progress bars
                        HStack(
                            alignment: .firstTextBaseline,
                            spacing: PrepPalTheme.Layout.elementSpacing) {
                            CompactMacroBar(label: "P", current: goals.macros.protein, goal: Double(goals.targetProteinPerKg))
                            CompactMacroBar(label: "C", current: goals.macros.carbs, goal: Double(goals.targetCarbs))
                            CompactMacroBar(label: "F", current: goals.macros.fat, goal: Double(goals.targetFat))
                        }
                        
                        // Expand button
                        Button(action: { withAnimation { isExpanded.toggle() } }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(PrepPalTheme.Colors.gray400)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(GeometryReader { geometry in
                Color.clear.preference(key: HeaderHeightKey.self, value: geometry.size.height)
            })
        }
        .onPreferenceChange(HeaderHeightKey.self) { height in
            headerHeight = height
        }
        .overlay(expandedOverlay, alignment: .top)
        .background(PrepPalTheme.Colors.cardBackground)
    }
    
    @ViewBuilder
    private var expandedOverlay: some View {
        if isExpanded, let goals = goals {
            VStack(spacing: 0) {
                VStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                    MacroDetailRow(
                        label: "Protein",
                        achieved: Int(goals.macros.protein),
                        goal: Int(goals.targetProteinPerKg * 100),
                        progress: goals.macros.protein / (Double(goals.targetProteinPerKg) * 100)
                    )
                    
                    MacroDetailRow(
                        label: "Carbs",
                        achieved: Int(goals.macros.carbs),
                        goal: goals.targetCarbs,
                        progress: goals.macros.carbs / Double(goals.targetCarbs)
                    )
                    
                    MacroDetailRow(
                        label: "Fat",
                        achieved: Int(goals.macros.fat),
                        goal: goals.targetFat,
                        progress: goals.macros.fat / Double(goals.targetFat)
                    )
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                Rectangle()
                    .fill(PrepPalTheme.Colors.gray400)
                    .frame(width: 36, height: 4)
                    .cornerRadius(2)
                    .padding(.top, 8)
            }
            .background(PrepPalTheme.Colors.cardBackground)
            .offset(y: headerHeight + dragOffset)
            .gesture(
                DragGesture()
                .onChanged { value in
                    withAnimation(.interactiveSpring()) {
                        dragOffset = value.translation.height
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = -50 // Swipe up threshold
                    withAnimation(.spring()) {
                        if value.translation.height < threshold {
                            isExpanded = false
                        }
                        dragOffset = 0
                    }
                }
            )
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

struct HeaderHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Supporting Views
private struct CompactMacroBar: View {
    let label: String
    let current: Double
    let goal: Double
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(label)
                .font(PrepPalTheme.Typography.caption)
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .frame(width: 32)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(PrepPalTheme.Colors.primary.opacity(0.3))
                        .frame(height: 4)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(PrepPalTheme.Colors.primary)
                        .frame(width: geo.size.width * min(1.0, current / goal), height: 4)
                }
            }
            .frame(width: 32, height: 4)
        }
        .frame(height: 30)
    }
}

private struct MacroDetailRow: View {
    let label: String
    let achieved: Int
    let goal: Int
    let progress: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Spacer()
            
            Text("\(achieved)g")
                .font(PrepPalTheme.Typography.headerMedium.bold())
                .foregroundColor(PrepPalTheme.Colors.gray600)
            
            Text("/ \(goal)g")
                .font(PrepPalTheme.Typography.headerMedium)
                .foregroundColor(PrepPalTheme.Colors.gray400)
        }.padding(.vertical)
    }
}

#Preview {
    ChatCombinedHeaderView(
        onSettingsPressed: {},
        onCalendarPressed: {},
        goals: NutritionGoals(
            macros: MacroGoal(
                protein: 150,
                carbs: 200,
                fat: 60,
                calories: 2000
            ),
            calorieGoal: 2000,
            targetProteinPerKg: 2.0,
            targetCarbs: 200,
            targetFat: 60,
            goalType: .maintenance,
            dietaryPattern: .balanced
        )
    )
}
