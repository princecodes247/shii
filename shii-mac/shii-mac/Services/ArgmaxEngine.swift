import Foundation
import WhisperKit
import SpeakerKit

class ArgmaxEngine: TranscriptionEngine {
    weak var delegate: TranscriptionEngineDelegate?
    
    private var whisperKit: WhisperKit?
    private var speakerKit: SpeakerKit?
    
    private var accumulatedSamples: [Float] = []
    private var isRecording = false
    private var transcriptionTask: Task<Void, Never>?
    private let sampleRate: Double = 16000.0
    
    func loadModel() async throws {
        Task { @MainActor in
            self.delegate?.engine(self, didUpdateProgress: 0.1)
        }
        
        let wk = try await WhisperKit()
        
        Task { @MainActor in
            self.delegate?.engine(self, didUpdateProgress: 0.5)
        }
        
        let sk = try await SpeakerKit()
        
        self.whisperKit = wk
        self.speakerKit = sk
        
        Task { @MainActor in
            self.delegate?.engine(self, didUpdateProgress: 1.0)
            self.delegate?.engineDidLoad(self)
        }
    }
    
    func start() throws {
        guard whisperKit != nil, speakerKit != nil else {
            throw NSError(domain: "ArgmaxEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Models not loaded"])
        }
        
        accumulatedSamples = []
        isRecording = true
        
        startTranscriptionLoop()
    }
    
    func ingestAudio(samples: [Float], sampleRate: Double) {
        DispatchQueue.main.async {
            self.accumulatedSamples.append(contentsOf: samples)
        }
    }
    
    func stop() {
        isRecording = false
        transcriptionTask?.cancel()
    }
    
    private func startTranscriptionLoop() {
        transcriptionTask?.cancel()
        
        transcriptionTask = Task {
            while !Task.isCancelled && isRecording {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                guard let wk = self.whisperKit else { continue }
                
                let samplesToTranscribe = await MainActor.run { return self.accumulatedSamples }
                
                if samplesToTranscribe.count > Int(sampleRate) {
                    do {
                        let transcription = try await wk.transcribe(audioArray: samplesToTranscribe)
                        if let text = transcription.first?.text, !text.isEmpty {
                            await MainActor.run {
                                self.delegate?.engine(self, didUpdateText: text)
                            }
                        }
                    } catch {
                        print("Argmax transcription loop error: \(error)")
                    }
                }
            }
        }
    }
    
    func generateFinalDiarizedTranscript(fallbackText: String) async -> [TranscriptItem] {
        guard let wk = whisperKit, let sk = speakerKit else {
            return [TranscriptItem(timestamp: "00:00", speaker: "Unknown", text: fallbackText)]
        }
        
        var audioArray = await MainActor.run { return self.accumulatedSamples }
        guard audioArray.count > 0 else {
            return [TranscriptItem(timestamp: "00:00", speaker: "Unknown", text: fallbackText)]
        }
        
        // Pad with 1 second of silence (16000 samples at 16kHz) to prevent the final words from being cut off
        audioArray.append(contentsOf: Array(repeating: Float(0), count: 16000))
        
        do {
            let transcription = try await wk.transcribe(audioArray: audioArray)
            let diarization = try await sk.diarize(audioArray: audioArray)
            
            let speakerSegments = diarization.addSpeakerInfo(to: transcription)
            
            var items: [TranscriptItem] = []
            
            for group in speakerSegments {
                for segment in group {
                    items.append(TranscriptItem(
                        timestamp: formatTimestamp(TimeInterval(segment.startTime)),
                        speaker: segment.speaker.description,
                        text: segment.text
                    ))
                }
            }
            
            if items.isEmpty {
                return [TranscriptItem(timestamp: "00:00", speaker: "Unknown", text: fallbackText)]
            }
            
            return items
            
        } catch {
            print("Failed to generate final diarized transcript: \(error)")
            return [TranscriptItem(timestamp: "00:00", speaker: "Unknown", text: fallbackText)]
        }
    }
    
    private func formatTimestamp(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
