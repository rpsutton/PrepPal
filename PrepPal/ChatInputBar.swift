import SwiftUI

// MARK: - Enhanced Chat Input Bar
struct ChatInputBar: View {
    @Binding var messageText: String
    let onSend: () -> Void
    let onCamera: () -> Void
    
    @State private var isEditing = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(PrepPalTheme.Colors.border)
            
            HStack(spacing: PrepPalTheme.Layout.elementSpacing) {
                // Camera Button
                Button(action: onCamera) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 18))
                        .foregroundColor(PrepPalTheme.Colors.gray600)
                        .frame(width: 44, height: 44)
                        .background(PrepPalTheme.Colors.gray100)
                        .clipShape(RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                .stroke(PrepPalTheme.Colors.border, lineWidth: 1)
                        )
                        .shadow(color: PrepPalTheme.Colors.shadow,
                                radius: PrepPalTheme.Layout.shadowRadius/3,
                                x: 0, y: PrepPalTheme.Layout.shadowY/3)
                }
                
                // Text Input
                ZStack(alignment: .trailing) {
                    TextField("Message PrepPal...", text: $messageText, axis: .vertical)
                        .focused($isTextFieldFocused)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(minHeight: 44)
                        .background(
                            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                .fill(PrepPalTheme.Colors.gray100)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: PrepPalTheme.Layout.cornerRadius)
                                .stroke(
                                    isTextFieldFocused ?
                                        PrepPalTheme.Colors.primary.opacity(0.5) :
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
                    
                    // Clear button when editing
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
            .background(PrepPalTheme.Colors.background.shadow(
                color: PrepPalTheme.Colors.shadow,
                radius: 8,
                x: 0,
                y: -4
            ))
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
                }
                
                // Add a slight delay before performing the action
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    action()
                    
                    // Reset the pressed state
                    withAnimation {
                        isPressed = false
                    }
                }
            }
        }) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isEnabled ? PrepPalTheme.Colors.primary : PrepPalTheme.Colors.gray400)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .opacity(isEnabled ? 1.0 : 0.6)
                .shadow(color: isEnabled ? PrepPalTheme.Colors.primary.opacity(0.3) : .clear,
                        radius: 4, x: 0, y: 2)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Quick Actions
struct QuickActions: View {
    let actions: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(actions, id: \.self) { action in
                    ActionChip(text: action) {
                        onSelect(action)
                    }
                }
            }
            .padding(.horizontal, PrepPalTheme.Layout.basePadding)
            .padding(.vertical, 8)
        }
        .background(PrepPalTheme.Colors.background)
    }
}

// MARK: - Action Chip
struct ActionChip: View {
    let text: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            // Add a slight delay before performing the action
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
                
                // Reset the pressed state
                withAnimation {
                    isPressed = false
                }
            }
        }) {
            Text(text)
                .font(PrepPalTheme.Typography.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(PrepPalTheme.Colors.gray100)
                        .overlay(
                            Capsule()
                                .stroke(PrepPalTheme.Colors.primary.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(PrepPalTheme.Colors.gray600)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}

// MARK: - Voice Input Button (Optional)
struct VoiceInputButton: View {
    @Binding var isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isRecording.toggle()
            }
            
            if isRecording {
                onStart()
            } else {
                onStop()
            }
        }) {
            Image(systemName: isRecording ? "waveform" : "mic.fill")
                .font(.system(size: 18))
                .foregroundColor(isRecording ? .white : PrepPalTheme.Colors.gray600)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isRecording ? PrepPalTheme.Colors.accentRed : PrepPalTheme.Colors.gray100)
                )
                .overlay(
                    Circle()
                        .stroke(
                            isRecording ?
                                PrepPalTheme.Colors.accentRed.opacity(0.3) :
                                PrepPalTheme.Colors.border,
                            lineWidth: 1
                        )
                )
                .shadow(color: isRecording ?
                            PrepPalTheme.Colors.accentRed.opacity(0.3) :
                            PrepPalTheme.Colors.shadow,
                        radius: isRecording ? 4 : 2,
                        x: 0, y: isRecording ? 2 : 1)
        }
        .scaleEffect(isRecording ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        QuickActions(actions: ["More protein", "Healthy snacks", "Meal prep ideas"]) { _ in
            // Action handler
        }
        
        ChatInputBar(
            messageText: .constant(""),
            onSend: {},
            onCamera: {}
        )
        
        VStack {
            Text("Pressed Send Button")
            SendButton(
                isEnabled: true,
                action: {}
            )
        }
        
        VStack {
            Text("Disabled Send Button")
            SendButton(
                isEnabled: false,
                action: {}
            )
        }
        
        VStack {
            Text("Voice Input - Not Recording")
            VoiceInputButton(
                isRecording: .constant(false),
                onStart: {},
                onStop: {}
            )
        }
        
        VStack {
            Text("Voice Input - Recording")
            VoiceInputButton(
                isRecording: .constant(true),
                onStart: {},
                onStop: {}
            )
        }
    }
    .padding()
    .background(PrepPalTheme.Colors.background)
}
