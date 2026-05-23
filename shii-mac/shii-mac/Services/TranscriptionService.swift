import Foundation
import AVFoundation
class TranscriptionService: TranscriptionEngineDelegate {
    private let audioRecorder = AudioRecorder()
    
    var engine: TranscriptionEngine
    
    var isRecording = false
    var isModelLoaded = false
    var modelLoadingProgress: Double = 0.0
    var currentTranscript = "Initializing AI model..."
    var currentAudioFileURL: URL?
    
    private let sampleRate: Double = 16000.0
    
    init(engine: TranscriptionEngine) {
        self.engine = engine
        self.engine.delegate = self
        Task {
            try? await self.engine.loadModel()
        }
    }
    
    // MARK: - TranscriptionEngineDelegate
    
    func engine(_ engine: TranscriptionEngine, didUpdateProgress progress: Double) {
        self.modelLoadingProgress = progress
        self.currentTranscript = "Loading: \(Int(progress * 100))%"
    }
    
    func engineDidLoad(_ engine: TranscriptionEngine) {
        self.isModelLoaded = true
        if !self.isRecording {
            self.currentTranscript = "Ready."
        }
    }
    
    func engine(_ engine: TranscriptionEngine, didUpdateText text: String) {
        self.currentTranscript = text
    }
    
    func engine(_ engine: TranscriptionEngine, didUpdateTokenTimings timings: Any?) {
        // Not needed directly in service
    }
    
    func engine(_ engine: TranscriptionEngine, didFailWithError error: Error) {
        print("Engine failed: \(error)")
        self.currentTranscript = "Engine failed."
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
        guard isModelLoaded else {
            print("ASR Manager not ready")
            throw NSError(domain: "TranscriptionService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Model not loaded yet."])
        }
        
        audioRecorder.onAudioBuffer = { [weak self] buffer in
            self?.processAudio(buffer: buffer)
        }
        
        self.currentAudioFileURL = try audioRecorder.startRecording()
        print("Recording to: \(self.currentAudioFileURL?.path ?? "")")
        
        isRecording = true
        currentTranscript = "Listening..."
        
        try engine.start()
    }
    
    func stopRecording() {
        audioRecorder.stopRecording()
        isRecording = false
        engine.stop()
    }
    
    func generateFinalDiarizedTranscript() async -> [TranscriptItem] {
        return await engine.generateFinalDiarizedTranscript(fallbackText: currentTranscript)
    }
    
    private func processAudio(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = Int(buffer.frameLength)
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameLength))
        
        engine.ingestAudio(samples: samples, sampleRate: sampleRate)
    }
}
