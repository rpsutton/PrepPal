import SwiftUI

// MARK: - Enhanced Chat Input Bar
public struct ChatInputBar: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let onCamera: () -> Void
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool
    
    public var body: some View {
        VStack(spacing: 0) {
            // Input container
            HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                // Camera Button
                InputBarButton(
                    icon: "camera.fill",
                    action: onCamera
                )
                
                // Text Input
                ZStack(alignment: .trailing) {
                    TextField("Message PrepPal...", text: $messageText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .padding(.horizontal, PrepPalTheme.Layout.basePadding)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                .fill(PrepPalTheme.Colors.cardBackground)
                                .overlay(
                                    LinearGradient(
                                        colors: [
                                            PrepPalTheme.Colors.primary.opacity(0.03),
                                            PrepPalTheme.Colors.cardBackground
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                .stroke(
                                    isTextFieldFocused ?
                                        PrepPalTheme.Colors.primary.opacity(0.3) :
                                        PrepPalTheme.Colors.border,
                                    lineWidth: isTextFieldFocused ? 2 : 1
                                )
                        )
                        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                        .font(PrepPalTheme.Typography.bodyRegular)
                        .onChange(of: messageText) { _ in
                            isEditing = true
                        }
                        .onSubmit {
                            if !messageText.isEmpty {
                                onSend()
                            }
                        }
                    
                    // Clear button
                    if isEditing && !messageText.isEmpty {
                        Button(action: {
                            messageText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(PrepPalTheme.Colors.gray400)
                                .padding(.trailing, 12)
                        }
                    }
                }
                
                // Send Button
                SendButton(
                    isEnabled: !messageText.isEmpty,
                    action: onSend
                )
            }
            .padding(PrepPalTheme.Layout.basePadding)
            .background(
                PrepPalTheme.Colors.background
                    .shadow(
                        color: PrepPalTheme.Colors.shadow,
                        radius: PrepPalTheme.Layout.shadowRadius,
                        y: -PrepPalTheme.Layout.shadowY
                    )
            )
        }
    }
}

// MARK: - Input Bar Button
struct InputBarButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                action()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(PrepPalTheme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(PrepPalTheme.Colors.primary.opacity(0.1))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        
    }
}

// MARK: - Send Button
struct SendButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if isEnabled {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                    action()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
        }) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isEnabled ? PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        ChatInputBar(
            messageText: .constant(""),
            onSend: {},
            onCamera: {}
        )
    }
    .padding(.top)
    .background(PrepPalTheme.Colors.background)
}
