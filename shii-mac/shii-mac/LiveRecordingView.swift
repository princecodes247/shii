import SwiftUI
import Combine

struct LiveRecordingView: View {
    @Environment(AppState.self) private var appState
    @State private var elapsedTime: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 12) {
            // Pulse dot
            Circle()
                .fill(Color.brandAccent)
                .frame(width: 8, height: 8)
                .opacity(appState.transcriptionService.isRecording ? 1.0 : 0.4)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: appState.transcriptionService.isRecording)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Recording...")
                    .font(.system(size: 13, weight: .medium, design: .default))
                    .foregroundColor(.brandTextMain)
                
                Text(appState.transcriptionService.currentTranscript)
                    .font(.system(size: 11, design: .default))
                    .foregroundColor(.brandTextMuted)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(timeString(from: elapsedTime))
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(.brandTextMuted)
                .onReceive(timer) { _ in
                    if let startTime = appState.activeSession?.startTime {
                        elapsedTime = Date().timeIntervalSince(startTime)
                    }
                }
            
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
        .onAppear {
            if let startTime = appState.activeSession?.startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
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
