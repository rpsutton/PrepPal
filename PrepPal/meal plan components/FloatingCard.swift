import SwiftUI

struct FloatingCard<Content: View>: View {
    @Binding var isPresented: Bool
    let content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    
                    VStack {
                        // Drag indicator
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(PrepPalTheme.Colors.gray400)
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)
                        
                        content()
                    }
                    .frame(maxWidth: .infinity)
                    .background(PrepPalTheme.Colors.cardBackground)
                    .cornerRadius(PrepPalTheme.Layout.cornerRadius)
                    .shadow(color: PrepPalTheme.Colors.shadow, radius: 10)
                    .transition(.move(edge: .bottom))
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                if gesture.translation.height > 50 {
                                    withAnimation {
                                        isPresented = false
                                    }
                                }
                            }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

