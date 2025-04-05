import SwiftUI

struct RecipeInstructionsView: View {
    let meal: Meal
    let expandedSection: RecipeSection?
    @Binding var completedSteps: Set<Int>
    @Binding var activeTimers: [Int: Timer]
    @Binding var remainingTimes: [Int: Int]
    @Binding var stepTimers: [Int: Int]
    var toggleAction: ((RecipeSection) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            RecipeSectionHeader(title: "Instructions", section: .instructions, expandedSection: expandedSection, toggleAction: toggleAction)
            
            if expandedSection == .instructions || expandedSection == nil {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(meal.steps.enumerated()), id: \.element) { index, instruction in
                        HStack(alignment: .top, spacing: 12) {
                            // Step number or completion indicator
                            Button(action: {
                                toggleStep(index)
                            }) {
                                if completedSteps.contains(index) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(PrepPalTheme.Colors.primary)
                                        .font(.system(size: 24))
                                } else {
                                    Text("\(index + 1)")
                                        .font(PrepPalTheme.Typography.headerMedium)
                                        .foregroundColor(PrepPalTheme.Colors.primary)
                                        .frame(width: 24, height: 24)
                                        .background(Circle().stroke(PrepPalTheme.Colors.primary, lineWidth: 1.5))
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                // Instruction text
                                Text(instruction)
                                    .font(PrepPalTheme.Typography.bodyRegular)
                                    .foregroundColor(completedSteps.contains(index) ? PrepPalTheme.Colors.gray400 : PrepPalTheme.Colors.gray600)
                                    .strikethrough(completedSteps.contains(index))
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                // Timer control (if applicable to this step)
                                if let duration = RecipeTimerUtils.getTimerDuration(for: instruction) {
                                    timerControlView(for: index, duration: duration)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(PrepPalTheme.Colors.cardBackground)
        .cornerRadius(PrepPalTheme.Layout.cornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 2, y: 1)
    }
    
    // MARK: - Timer Control View
    private func timerControlView(for stepIndex: Int, duration: Int) -> some View {
        Group {
            if activeTimers[stepIndex] != nil, let remaining = remainingTimes[stepIndex] {
                // Active timer
                HStack {
                    Text(RecipeTimerUtils.formatTime(remaining))
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .foregroundColor(PrepPalTheme.Colors.primary)
                        .monospacedDigit()
                    
                    Button(action: {
                        stopTimer(for: stepIndex)
                    }) {
                        Text("Cancel")
                            .font(PrepPalTheme.Typography.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(PrepPalTheme.Colors.accentRed)
                            .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    }
                }
            } else {
                // Start timer button
                Button(action: {
                    startTimer(for: stepIndex, duration: duration)
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("Start \(duration) min timer")
                            .font(PrepPalTheme.Typography.caption)
                    }
                    .foregroundColor(PrepPalTheme.Colors.info)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(PrepPalTheme.Colors.info.opacity(0.1))
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    // Toggle step completion
    private func toggleStep(_ index: Int) {
        if completedSteps.contains(index) {
            completedSteps.remove(index)
        } else {
            completedSteps.insert(index)
            // If this step has an active timer, stop it
            if activeTimers[index] != nil {
                stopTimer(for: index)
            }
        }
    }
    
    // Start timer for step
    private func startTimer(for stepIndex: Int, duration: Int) {
        // Store the intended duration
        stepTimers[stepIndex] = duration
        
        // Set the remaining time
        remainingTimes[stepIndex] = duration * 60
        
        // Start the timer
        activeTimers[stepIndex] = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let remaining = remainingTimes[stepIndex], remaining > 0 {
                remainingTimes[stepIndex] = remaining - 1
            } else {
                // Timer completed
                stopTimer(for: stepIndex)
                // Play a sound or notification here in production
            }
        }
    }
    
    // Stop timer for step
    private func stopTimer(for stepIndex: Int) {
        activeTimers[stepIndex]?.invalidate()
        activeTimers[stepIndex] = nil
        remainingTimes[stepIndex] = 0
    }
}
