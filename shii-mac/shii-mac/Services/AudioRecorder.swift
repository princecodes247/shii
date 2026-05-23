import Foundation
import AVFoundation

class AudioRecorder {
    private let audioEngine = AVAudioEngine()
    private var sinkNode: AVAudioSinkNode?
    private var audioFile: AVAudioFile?
    private var fileURL: URL?
    
    // Callback to pass 16kHz float buffers to the transcription engine
    var onAudioBuffer: ((AVAudioPCMBuffer) -> Void)?
    
    private let sampleRate: Double = 16000.0
    
    init() {
        cleanupOldRecordings()
    }
    
    func startRecording() throws -> URL {
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Target format for transcription: 16kHz mono float
        guard let targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: sampleRate, channels: 1, interleaved: false) else {
            throw NSError(domain: "AudioRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create target format"])
        }
        
        // Setup sink node to keep the graph running
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
            throw NSError(domain: "AudioRecorder", code: 3, userInfo: [NSLocalizedDescriptionKey: "Format conversion not supported."])
        }
        
        // Setup AVAudioFile for .m4a recording
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording-\(UUID().uuidString).m4a"
        let url = tempDir.appendingPathComponent(fileName)
        self.fileURL = url
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: inputFormat.sampleRate,
            AVNumberOfChannelsKey: inputFormat.channelCount,
            AVEncoderBitRateKey: 128000
        ]
        
        audioFile = try AVAudioFile(forWriting: url, settings: settings, commonFormat: inputFormat.commonFormat, interleaved: inputFormat.isInterleaved)
        
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 8192, format: inputFormat) { [weak self] (buffer, when) in
            guard let self = self else { return }
            
            // 1. Write the original buffer to the file
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Failed to write audio buffer to file: \(error)")
            }
            
            // 2. Convert and pass to transcription engine
            let capacity = AVAudioFrameCount(targetFormat.sampleRate * Double(buffer.frameLength) / inputFormat.sampleRate)
            guard let outputBuffer = AVAudioPCMBuffer(pcmFormat: targetFormat, frameCapacity: capacity + 1024) else { return }
            
            var convertError: NSError? = nil
            var inputPassed = false
            let status = converter.convert(to: outputBuffer, error: &convertError) { inNumPackets, outStatus in
                if inputPassed {
                    outStatus.pointee = .noDataNow
                    return nil
                }
                inputPassed = true
                outStatus.pointee = .haveData
                return buffer
            }
            
            if status != .error, convertError == nil {
                self.onAudioBuffer?(outputBuffer)
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return url
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioFile = nil // Close the file
    }
    
    func cleanupOldRecordings() {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory
        
        do {
            let files = try fileManager.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: [.creationDateKey])
            let now = Date()
            
            for fileURL in files {
                guard fileURL.pathExtension == "m4a" else { continue }
                
                let attributes = try fileURL.resourceValues(forKeys: [.creationDateKey])
                if let creationDate = attributes.creationDate {
                    // Check if older than 24 hours (86400 seconds)
                    if now.timeIntervalSince(creationDate) > 86400 {
                        try fileManager.removeItem(at: fileURL)
                        print("Deleted old audio file: \(fileURL.lastPathComponent)")
                    }
                }
            }
        } catch {
            print("Failed to clean up old recordings: \(error)")
        }
    }
}
