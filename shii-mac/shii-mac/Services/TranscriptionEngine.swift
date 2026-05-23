import Foundation

@MainActor
protocol TranscriptionEngineDelegate: AnyObject {
    func engine(_ engine: TranscriptionEngine, didUpdateProgress progress: Double)
    func engineDidLoad(_ engine: TranscriptionEngine)
    func engine(_ engine: TranscriptionEngine, didUpdateText text: String)
    func engine(_ engine: TranscriptionEngine, didUpdateTokenTimings timings: Any?) // Use Any? or a generic type if needed, but since TokenTiming is specific to Parakeet we can abstract it or just leave it out if we don't need it outside. Actually, we use token timings to format the TranscriptItems inside the engine!
    func engine(_ engine: TranscriptionEngine, didFailWithError error: Error)
}

protocol TranscriptionEngine: AnyObject {
    var delegate: TranscriptionEngineDelegate? { get set }
    
    /// Called to initialize and load models.
    func loadModel() async throws
    
    /// Called when the recording session starts.
    func start() throws
    
    /// Ingests audio samples from the microphone (expected to be 16kHz float32).
    func ingestAudio(samples: [Float], sampleRate: Double)
    
    /// Called when the recording session stops.
    func stop()
    
    /// Generates the final formatted TranscriptItems after stopping.
    func generateFinalDiarizedTranscript(fallbackText: String) async -> [TranscriptItem]
    
    /// Transcribes and diarizes a completed audio file.
    func transcribeFile(url: URL) async throws -> [TranscriptItem]
}
