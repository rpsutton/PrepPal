import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView(content: {
            ChatView()
        })
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
