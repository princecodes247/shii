import Foundation
import AVFoundation
class TranscriptionService: TranscriptionEngineDelegate {
    private let audioEngine = AVAudioEngine()
    private var sinkNode: AVAudioSinkNode?
    
    var engine: TranscriptionEngine
    
    var isRecording = false
    var isModelLoaded = false
    var modelLoadingProgress: Double = 0.0
    var currentTranscript = "Initializing AI model..."
    
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
        
        try engine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
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
