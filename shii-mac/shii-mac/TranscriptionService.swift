import Foundation
import AVFoundation
import FluidAudio
import CoreML

@Observable
class TranscriptionService {
    private let audioEngine = AVAudioEngine()
    private var sinkNode: AVAudioSinkNode?
    
    var isRecording = false
    var isModelLoaded = false
    var modelLoadingProgress: Double = 0.0
    var currentTranscript = "Initializing AI model..."
    var currentTokenTimings: [TokenTiming]? = nil
    
    private var asrManager: AsrManager?
    private var diarizer: LSEENDDiarizer?
    private var accumulatedSamples: [Float] = []
    private var diarizerSamplesProcessed: Int = 0
    private var transcriptionTask: Task<Void, Never>?
    private let sampleRate: Double = 16000.0
    
    // Extracted diarization segments
    var diarizationSegments: [DiarizerSegment] = []
    
    init() {
        Task {
            await setupModel()
        }
    }
    
    private func setupModel() async {
        var lastUpdateTime: Date = Date()
        
        do {
            let models = try await AsrModels.downloadAndLoad(version: .v2) { progress in
                let now = Date()
                if now.timeIntervalSince(lastUpdateTime) > 0.1 || progress.fractionCompleted >= 1.0 {
                    lastUpdateTime = now
                    DispatchQueue.main.async {
                        self.modelLoadingProgress = progress.fractionCompleted
                        self.currentTranscript = "Loading: \(Int(progress.fractionCompleted * 100))%"
                    }
                }
            }
            let manager = AsrManager(config: .default)
            try await manager.loadModels(models)
            
            // 2. Initialize Diarizer Model
            let d = LSEENDDiarizer(timelineConfig: nil)
            try await d.initialize(variant: .ami, stepSize: .step100ms, computeUnits: .cpuOnly) { progress in
                // We could combine progress here, but for simplicity, we'll just let ASR progress dominate
                // or just leave it.
            }
            
            DispatchQueue.main.async {
                self.asrManager = manager
                self.diarizer = d
                self.isModelLoaded = true
                if !self.isRecording {
                    self.currentTranscript = "Ready."
                }
            }
        } catch {
            print("Failed to load FluidAudio model: \(error)")
            DispatchQueue.main.async {
                self.currentTranscript = "Failed to load AI model."
            }
        }
    }
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func startRecording() throws {
        guard asrManager != nil else {
            print("ASR Manager not ready")
            throw NSError(domain: "TranscriptionService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model not loaded yet."])
        }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Target format: 16kHz mono float
        guard let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false) else {
            throw NSError(domain: "TranscriptionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create target format"])
        }
        
        // Use an AVAudioSinkNode to terminate the graph safely.
        if sinkNode == nil {
            sinkNode = AVAudioSinkNode { (timestamp, frames, audioBufferList) -> OSStatus in
                return noErr
            }
        }
        
        if let sink = sinkNode, !audioEngine.attachedNodes.contains(sink) {
            audioEngine.attach(sink)
        }
        if let sink = sinkNode {
            audioEngine.connect(inputNode, to: sink, format: inputFormat)
        }
        
        guard let converter = AVAudioConverter(from: inputFormat, to: targetFormat) else {
            throw NSError(domain: "TranscriptionService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Format conversion not supported."])
        }
        
        accumulatedSamples = []
        diarizerSamplesProcessed = 0
        diarizationSegments = []
        diarizer?.reset()
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { [weak self] (buffer, when) in
            // Calculate capacity for the converted buffer
            let capacity = AVAudioFrameCount(targetFormat.sampleRate * Double(buffer.frameLength) / inputFormat.sampleRate)
            // Add a small padding to capacity to be safe
            guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity + 1024) else { return }
            
            var error: NSError? = nil
            var inputPassed = false
            let status = converter.convert(to: outputBuffer, error: &error) { inNumPackets, outStatus in
                if inputPassed {
                    outStatus.pointee = .noDataNow
                    return nil
                }
                inputPassed = true
                outStatus.pointee = .haveData
                return buffer
            }
            
            if status != .error, error == nil {
                self?.processAudio(buffer: outputBuffer)
            }
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        isRecording = true
        currentTranscript = "Listening..."
        
        startTranscriptionLoop()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isRecording = false
        transcriptionTask?.cancel()
        
        // Finalize diarizer session
        if let d = diarizer {
            do {
                try d.finalizeSession()
                self.diarizationSegments = d.timeline.speakers.values.flatMap { $0.finalizedSegments }.sorted { $0.startFrame < $1.startFrame }
            } catch {
                print("Failed to finalize diarizer: \(error)")
            }
        }
    }
    
    func generateFinalDiarizedTranscript() -> [TranscriptItem] {
        guard let timings = currentTokenTimings, !timings.isEmpty else {
            // Fallback
            let speaker = diarizationSegments.first?.speakerLabel ?? "Unknown"
            return [TranscriptItem(timestamp: "00:00", speaker: speaker, text: currentTranscript)]
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
    
    private func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        
        // Append to our running buffer safely (in a real app, use a thread-safe queue/actor, but for prototype this is okay on the tap thread, as long as we copy it before async)
        // To be safe, we should dispatch this to a serial queue or actor, but we'll keep it simple for prototyping.
        DispatchQueue.main.async {
            self.accumulatedSamples.append(contentsOf: samples)
        }
    }
    
    private func startTranscriptionLoop() {
        transcriptionTask?.cancel()
        
        transcriptionTask = Task {
            do {
                var decoderState = try TdtDecoderState()
                
                while !Task.isCancelled && isRecording {
                    // Wait for a chunk of audio to build up (e.g., 2 seconds)
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    
                    guard let manager = self.asrManager, let diarizer = self.diarizer else { continue }
                    
                    // Snapshot the current samples on the main thread
                    let samplesToTranscribe = await MainActor.run { return self.accumulatedSamples }
                    
                    if samplesToTranscribe.count > Int(sampleRate) { // at least 1 second of audio
                        // 1. ASR
                        let result = try await manager.transcribe(samplesToTranscribe, decoderState: &decoderState)
                        
                        // 2. Diarization
                        // Only feed new samples to the diarizer
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
                                self.currentTranscript = result.text
                                self.currentTokenTimings = result.tokenTimings
                            }
                        }
                    }
                }
            } catch {
                print("Transcription loop error: \(error)")
            }
        }
    }
}
