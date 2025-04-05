import SwiftUI

struct FloatingTimerView: View {
    let stepIndex: Int
    let remaining: Int
    let stopTimer: (Int) -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.white)
            Text(RecipeTimerUtils.formatTime(remaining))
                .font(PrepPalTheme.Typography.bodyRegular)
                .foregroundColor(.white)
                .monospacedDigit()
            
            Button(action: {
                stopTimer(stepIndex)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(PrepPalTheme.Colors.secondary)
        .cornerRadius(PrepPalTheme.Layout.pillCornerRadius)
        .shadow(color: PrepPalTheme.Colors.shadow, radius: 4, y: 2)
        .padding(PrepPalTheme.Layout.basePadding)
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
