import Foundation
import SwiftUI
import Observation

@Observable
class AppState {
    var meetings: [Meeting]
    var activeSession: ActiveSession?
    var transcriptionService = TranscriptionService()
    
    init(meetings: [Meeting] = Meeting.mockData) {
        self.meetings = meetings
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
    
    func endSession() {
        transcriptionService.stopRecording()
        
        // Mock saving the session to a meeting
        if let session = activeSession {
            let newMeeting = Meeting(
                title: "New Recording",
                date: session.startTime,
                durationMinutes: Int(Date().timeIntervalSince(session.startTime) / 60),
                summaryPreview: transcriptionService.currentTranscript,
                summary: transcriptionService.currentTranscript,
                participantsCount: 1,
                tasks: [],
                decisions: [],
                transcript: [TranscriptItem(timestamp: "00:00", speaker: "You", text: transcriptionService.currentTranscript)],
                isImportant: false
            )
            meetings.insert(newMeeting, at: 0)
        }
        
        activeSession = nil
        transcriptionService.currentTranscript = "Waiting for speech..."
    }
    
    func clearMeetings() {
        meetings = []
    }
    
    func loadMockData() {
        meetings = Meeting.mockData
    }
}

struct ActiveSession {
    let startTime: Date
    var transcribingText: String = "Transcribing live"
}
