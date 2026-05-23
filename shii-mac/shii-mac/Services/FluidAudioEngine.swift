import Foundation
import FluidAudio
import CoreML

class FluidAudioEngine: TranscriptionEngine {
    weak var delegate: TranscriptionEngineDelegate?
    
    private var asrManager: AsrManager?
    private var diarizer: LSEENDDiarizer?
    private var accumulatedSamples: [Float] = []
    private var diarizerSamplesProcessed: Int = 0
    private var transcriptionTask: Task<Void, Never>?
    private let sampleRate: Double = 16000.0
    
    private var currentTokenTimings: [TokenTiming]? = nil
    private var diarizationSegments: [DiarizerSegment] = []
    private var isRecording = false
    
    func loadModel() async throws {
        var lastUpdateTime: Date = Date()
        
        let models = try await AsrModels.downloadAndLoad(version: .v2) { progress in
            let now = Date()
            if now.timeIntervalSince(lastUpdateTime) > 0.1 || progress.fractionCompleted >= 1.0 {
                lastUpdateTime = now
                Task { @MainActor in
                    self.delegate?.engine(self, didUpdateProgress: progress.fractionCompleted)
                }
            }
        }
        let manager = AsrManager(config: .default)
        try await manager.loadModels(models)
        
        let d = LSEENDDiarizer(timelineConfig: nil)
        try await d.initialize(variant: .ami, stepSize: .step100ms, computeUnits: .cpuOnly) { _ in }
        
        self.asrManager = manager
        self.diarizer = d
        
        Task { @MainActor in
            self.delegate?.engineDidLoad(self)
        }
    }
    
    func start() throws {
        guard asrManager != nil else {
            throw NSError(domain: "FluidAudioEngine", code: 1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        accumulatedSamples = []
        diarizerSamplesProcessed = 0
        diarizationSegments = []
        currentTokenTimings = nil
        diarizer?.reset()
        isRecording = true
        
        startTranscriptionLoop()
    }
    
    func ingestAudio(samples: [Float], sampleRate: Double) {
        // Appends to buffer, locking could be needed in a real scenario but for now keeping it simple.
        DispatchQueue.main.async {
            self.accumulatedSamples.append(contentsOf: samples)
        }
    }
    
    func stop() {
        isRecording = false
        transcriptionTask?.cancel()
        
        if let d = diarizer {
            do {
                try d.finalizeSession()
                self.diarizationSegments = d.timeline.speakers.values.flatMap { $0.finalizedSegments }.sorted { $0.startFrame < $1.startFrame }
            } catch {
                print("Failed to finalize diarizer: \(error)")
            }
        }
    }
    
    private func startTranscriptionLoop() {
        transcriptionTask?.cancel()
        
        transcriptionTask = Task {
            do {
                var decoderState = try TdtDecoderState()
                
                while !Task.isCancelled && isRecording {
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    
                    guard let manager = self.asrManager, let diarizer = self.diarizer else { continue }
                    
                    let samplesToTranscribe = await MainActor.run { return self.accumulatedSamples }
                    
                    if samplesToTranscribe.count > Int(sampleRate) {
                        let result = try await manager.transcribe(samplesToTranscribe, decoderState: &decoderState)
                        
                        let processedCount = await MainActor.run { return self.diarizerSamplesProcessed }
                        if samplesToTranscribe.count > processedCount {
                            let newSamples = Array(samplesToTranscribe[processedCount...])
                            if let _ = try diarizer.process(samples: newSamples, sourceSampleRate: 16000) {
                                await MainActor.run {
                                    self.diarizationSegments = diarizer.timeline.speakers.values.flatMap { $0.finalizedSegments }.sorted { $0.startFrame < $1.startFrame }
                                }
                            }
                            await MainActor.run {
                                self.diarizerSamplesProcessed += newSamples.count
                            }
                        }
                        
                        await MainActor.run {
                            if !result.text.isEmpty {
                                self.currentTokenTimings = result.tokenTimings
                                self.delegate?.engine(self, didUpdateText: result.text)
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.delegate?.engine(self, didFailWithError: error)
                }
            }
        }
    }
    
    func generateFinalDiarizedTranscript(fallbackText: String) async -> [TranscriptItem] {
        guard let timings = currentTokenTimings, !timings.isEmpty else {
            let speaker = diarizationSegments.first?.speakerLabel ?? "Unknown"
            return [TranscriptItem(timestamp: "00:00", speaker: speaker, text: fallbackText)]
        }
        
        var items: [TranscriptItem] = []
        var currentSpeaker: String? = nil
        var currentText = ""
        var currentStartTime: TimeInterval = 0.0
        
        for timing in timings {
            let t = Float(timing.startTime)
            let speaker = self.diarizationSegments.first { $0.startTime <= t && $0.endTime >= t }?.speakerLabel ?? "Unknown"
            
            let cleanToken = timing.token.replacingOccurrences(of: "\u{2581}", with: " ")
            
            if speaker != currentSpeaker {
                if let cs = currentSpeaker, !currentText.trimmingCharacters(in: .whitespaces).isEmpty {
                    items.append(TranscriptItem(
                        timestamp: formatTimestamp(currentStartTime),
                        speaker: cs,
                        text: currentText.trimmingCharacters(in: .whitespaces)
                    ))
                }
                currentSpeaker = speaker
                currentText = cleanToken
                currentStartTime = timing.startTime
            } else {
                currentText += cleanToken
            }
        }
        
        if let cs = currentSpeaker, !currentText.trimmingCharacters(in: .whitespaces).isEmpty {
            items.append(TranscriptItem(
                timestamp: formatTimestamp(currentStartTime),
                speaker: cs,
                text: currentText.trimmingCharacters(in: .whitespaces)
            ))
        }
        
        return items
    }
    
    private func formatTimestamp(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
