import SwiftUI
import FirebaseCore

struct ContentView: View {
    
    var body: some View {
        ChatView()
            .background(
                PrepPalTheme.Colors.background
            )
            .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
        .environmentObject(UserProfileManager())
}
