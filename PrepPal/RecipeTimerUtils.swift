import SwiftUI

class RecipeTimerUtils {
    // Extract timer duration from step instruction text
    static func getTimerDuration(for instruction: String) -> Int? {
        // This is a simplified version. In production, you would use RegEx or more sophisticated parsing
        let lowercased = instruction.lowercased()
        
        // Check for common patterns like "cook for 20 minutes" or "bake for 25-30 min"
        if lowercased.contains("minute") || lowercased.contains(" min") {
            // Try to find numeric values
            let words = lowercased.components(separatedBy: .whitespacesAndNewlines)
            for (index, word) in words.enumerated() {
                if let number = Int(word), index + 1 < words.count {
                    if words[index + 1].contains("min") {
                        return number
                    }
                }
            }
            
            // If couldn't find exact number but contains time keywords, default to 5 minutes
            return 5
        }
        
        // No timer needed for this step
        return nil
    }
    
    // Calculate a rough total time for the recipe based on steps
    static func calculateTotalTime(steps: [String]) -> Int {
        var total = 0
        for instruction in steps {
            if let duration = getTimerDuration(for: instruction) {
                total += duration
            } else {
                // Assume 5 minutes for steps without timers
                total += 5
            }
        }
        return total
    }
    
    // Format seconds into a MM:SS string
    static func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
