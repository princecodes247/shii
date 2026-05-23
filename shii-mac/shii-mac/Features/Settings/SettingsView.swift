import SwiftUI

struct SettingsView: View {
    @AppStorage("transcriptionEngine") private var savedEngine: String = TranscriptionEngineType.argmax.rawValue
    @State private var transcriptionEngine: TranscriptionEngineType = .argmax
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.brandTextMain)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Transcription Engine")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.brandTextMain)
                
                Picker("Engine", selection: $transcriptionEngine) {
                    ForEach(TranscriptionEngineType.allCases) { engine in
                        Text(engine.rawValue).tag(engine)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: transcriptionEngine) { _, newValue in
                    appState.updateTranscriptionEngine(newValue)
                }
            }
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.brandCard))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandCardBorder, lineWidth: 1)
            )
            
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.brandBg)
        .onAppear {
            if let parsed = TranscriptionEngineType(rawValue: savedEngine) {
                transcriptionEngine = parsed
            }
        }
    }
}
