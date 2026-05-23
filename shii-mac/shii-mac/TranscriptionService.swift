import Foundation
import AVFoundation
import FluidAudio

@Observable
class TranscriptionService {
    private let audioEngine = AVAudioEngine()
    private var sinkNode: AVAudioSinkNode?
    
    var isRecording = false
    var isModelLoaded = false
    var modelLoadingProgress: Double = 0.0
    var currentTranscript = "Initializing AI model..."
    
    private var asrManager: AsrManager?
    private var accumulatedSamples: [Float] = []
    private var transcriptionTask: Task<Void, Never>?
    private let sampleRate: Double = 16000.0
    
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
            
            DispatchQueue.main.async {
                self.asrManager = manager
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
                    
                    guard let manager = self.asrManager else { continue }
                    
                    // Snapshot the current samples on the main thread
                    let samplesToTranscribe = await MainActor.run { return self.accumulatedSamples }
                    
                    if samplesToTranscribe.count > Int(sampleRate) { // at least 1 second of audio
                        let result = try await manager.transcribe(samplesToTranscribe, decoderState: &decoderState)
                        
                        await MainActor.run {
                            if !result.text.isEmpty {
                                self.currentTranscript = result.text
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
