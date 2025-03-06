import SwiftUI

// MARK: - Weekly Meal Plan Preview Card for Chat
struct WeeklyMealPlanPreview: View {
    let weeklyPlan: WeeklyMealPlan
    @Binding var showFullMealPlan: Bool
    @Binding var selectedDay: DailyMealPlan?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Weekly Meal Plan")
                    .font(PrepPalTheme.Typography.headerMedium)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Spacer()
                
                calendarButton
            }
            .padding()
            .background(PrepPalTheme.Colors.primary.opacity(0.05))
            .cornerRadius(PrepPalTheme.Layout.cornerRadius, corners: [.topLeft, .topRight])
            
            // Week days
            dayScrollView
            
            // Action button
            viewFullPlanButton
        }
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow,
                radius: PrepPalTheme.Layout.shadowRadius/2,
                x: 0,
                y: PrepPalTheme.Layout.shadowY/2)
    }
    
    // MARK: - Calendar Button
    private var calendarButton: some View {
        Button(action: {
            showFullMealPlan = true
        }) {
            Image(systemName: "calendar")
                .font(.system(size: 16))
                .foregroundColor(PrepPalTheme.Colors.primary)
                .padding(8)
                .background(PrepPalTheme.Colors.primary.opacity(0.1))
                .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        }
    }
    
    // MARK: - Day Scroll View
    private var dayScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(weeklyPlan.dailyPlans) { dailyPlan in
                    dayPreviewCard(for: dailyPlan)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Day Preview Card
    private func dayPreviewCard(for dailyPlan: DailyMealPlan) -> some View {
        Button(action: {
            selectedDay = dailyPlan
        }) {
            VStack(spacing: 12) {
                // Day of week with indicator for today
                ZStack {
                    Circle()
                        .fill(dailyPlan.isToday ? 
                              PrepPalTheme.Colors.primary : 
                              PrepPalTheme.Colors.gray100)
                        .frame(width: 36, height: 36)
                    
                    Text(String(dailyPlan.day.prefix(3)))
                        .font(PrepPalTheme.Typography.bodyRegular.bold())
                        .foregroundColor(dailyPlan.isToday ? 
                                        .white : 
                                        PrepPalTheme.Colors.gray600)
                }
                
                // Calories for the day
                Text("\(dailyPlan.macros.calories)")
                    .font(PrepPalTheme.Typography.bodyRegular)
                    .foregroundColor(PrepPalTheme.Colors.gray600)
                
                Text("cal")
                    .font(PrepPalTheme.Typography.caption)
                    .foregroundColor(PrepPalTheme.Colors.gray400)
                
                // Mini progress bars for macros
                VStack(spacing: 6) {
                    miniProgressBar(
                        value: dailyPlan.achievedMacros.protein,
                        total: dailyPlan.macros.protein,
                        color: PrepPalTheme.Colors.primary
                    )
                    
                    miniProgressBar(
                        value: dailyPlan.achievedMacros.carbs,
                        total: dailyPlan.macros.carbs,
                        color: PrepPalTheme.Colors.accentRed
                    )
                    
                    miniProgressBar(
                        value: dailyPlan.achievedMacros.fat,
                        total: dailyPlan.macros.fat,
                        color: PrepPalTheme.Colors.warning
                    )
                }
            }
            .padding()
            .frame(width: 100)
            .background(
                RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                    .fill(dailyPlan.isToday ? 
                          PrepPalTheme.Colors.primary.opacity(0.05) : 
                          PrepPalTheme.Colors.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                            .stroke(dailyPlan.isToday ? 
                                    PrepPalTheme.Colors.primary.opacity(0.3) : 
                                    PrepPalTheme.Colors.gray100, 
                                    lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Mini Progress Bar
    private func miniProgressBar(value: Double, total: Double, color: Color) -> some View {
        let progress = min(1.0, value / total)
        
        return ZStack(alignment: .leading) {
            // Background
            Rectangle()
                .fill(color.opacity(0.2))
                .frame(height: 4)
                .cornerRadius(2)
            
            // Progress
            Rectangle()
                .fill(color)
                .frame(width: 80 * progress, height: 4)
                .cornerRadius(2)
        }
        .frame(width: 80, height: 4)
    }
    
    // MARK: - View Full Plan Button
    private var viewFullPlanButton: some View {
        Button(action: {
            showFullMealPlan = true
        }) {
            Text("View Detailed Meal Plan")
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(PrepPalTheme.Colors.primary)
                .cornerRadius(PrepPalTheme.Layout.cornerRadius, corners: [.bottomLeft, .bottomRight])
        }
    }
}

// MARK: - Rounded Corner Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    WeeklyMealPlanPreview(
        weeklyPlan: WeeklyMealPlan.createSampleData(),
        showFullMealPlan: .constant(false),
        selectedDay: .constant(nil)
    )
    .padding()
    .background(PrepPalTheme.Colors.background)
}
