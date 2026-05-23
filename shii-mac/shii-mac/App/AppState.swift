import Foundation
import SwiftUI
import Observation

@Observable
class AppState {
    var meetings: [Meeting]
    var activeSession: ActiveSession?
    var transcriptionService: TranscriptionService
    
    init(meetings: [Meeting] = Meeting.mockData) {
        self.meetings = meetings
        
        let savedEngine = UserDefaults.standard.string(forKey: "transcriptionEngine") ?? TranscriptionEngineType.argmax.rawValue
        if savedEngine == TranscriptionEngineType.fluidAudio.rawValue {
            self.transcriptionService = TranscriptionService(engine: FluidAudioEngine())
        } else {
            self.transcriptionService = TranscriptionService(engine: ArgmaxEngine())
        }
    }
    
    func updateTranscriptionEngine(_ type: TranscriptionEngineType) {
        let newEngine: TranscriptionEngine
        switch type {
        case .fluidAudio:
            newEngine = FluidAudioEngine()
        case .argmax:
            newEngine = ArgmaxEngine()
        }
        
        if activeSession != nil {
            transcriptionService.stopRecording()
            // In a real app we might resume recording, but for now we just stop.
        }
        
        transcriptionService = TranscriptionService(engine: newEngine)
        UserDefaults.standard.set(type.rawValue, forKey: "transcriptionEngine")
    }
    
    func startSession() {
        transcriptionService.requestPermissions { [weak self] granted in
            guard let self = self, granted else {
                print("Microphone access denied")
                return
            }
            
            do {
                try self.transcriptionService.startRecording()
                self.activeSession = ActiveSession(startTime: Date())
            } catch {
                print("Failed to start audio engine: \(error)")
            }
        }
    }
    
    func endSession() async {
        guard let session = activeSession else { return }
        
        // Hide the active session from UI immediately
        activeSession = nil
        
        // If using ArgmaxEngine, keep recording for 5s after stop is clicked
        if transcriptionService.engine is ArgmaxEngine {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
        }
        
        transcriptionService.stopRecording()
        
        // Mock saving the session to a meeting
        let transcript = await transcriptionService.generateFinalDiarizedTranscript()
        let newMeeting = Meeting(
            title: "New Recording",
            date: session.startTime,
            durationMinutes: max(1, Int(Date().timeIntervalSince(session.startTime) / 60)),
            summaryPreview: transcriptionService.currentTranscript,
            summary: transcriptionService.currentTranscript,
            participantsCount: 1,
            tasks: [],
            decisions: [],
            transcript: transcript,
            audioFileURL: transcriptionService.currentAudioFileURL,
            isImportant: false
        )
        
        await MainActor.run {
            meetings.insert(newMeeting, at: 0)
            transcriptionService.currentTranscript = "Waiting for speech..."
        }
    }
    
    func clearMeetings() {
        meetings = []
    }
    
    func retranscribe(meetingId: UUID) {
        guard let index = meetings.firstIndex(where: { $0.id == meetingId }) else { return }
        var meeting = meetings[index]
        guard let fileURL = meeting.audioFileURL else { return }
        
        meeting.isRetranscribing = true
        meetings[index] = meeting
        
        Task {
            do {
                let newTranscript = try await transcriptionService.engine.transcribeFile(url: fileURL)
                await MainActor.run {
                    var updatedMeeting = self.meetings[index]
                    updatedMeeting.transcript = newTranscript
                    updatedMeeting.isRetranscribing = false
                    self.meetings[index] = updatedMeeting
                }
            } catch {
                print("Retranscription failed: \(error)")
                await MainActor.run {
                    var updatedMeeting = self.meetings[index]
                    updatedMeeting.isRetranscribing = false
                    self.meetings[index] = updatedMeeting
                }
            }
        }
    }
    
    func loadMockData() {
        meetings = Meeting.mockData
    }
}

struct ActiveSession {
    let startTime: Date
    var transcribingText: String = "Transcribing live"
}
