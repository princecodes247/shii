import SwiftUI

struct LiveRecordingView: View {
    @Environment(AppState.self) private var appState
    @State private var isPulsing = false
    
    var body: some View {
        let transcribingText = appState.activeSession?.transcribingText ?? "Transcribing live"
        
        HStack(spacing: 12) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(isPulsing ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 1.0).repeatForever(), value: isPulsing)
                .onAppear {
                    isPulsing = true
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Recording...")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.brandTextMain)
                
                Text(transcribingText)
                    .font(.system(size: 11, design: .default))
                    .foregroundColor(.brandTextMuted)
            }
            
            Spacer()
            
            Text("00:18:42")
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.brandTextMuted)
            
            // Stop button
            Button {
                appState.endSession()
            } label: {
                Image(systemName: "stop.circle.fill")
                    .foregroundColor(.brandTextMuted)
                    .font(.system(size: 18))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(Color.brandCard.opacity(0.5).cornerRadius(16))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandCardBorder, lineWidth: 1)
        )
    }
}

#Preview {
    let state = AppState()
    state.startSession()
    
    return LiveRecordingView()
        .environment(state)
        .padding()
        .background(Color.gray.opacity(0.1))
}
