import Foundation
import SwiftUI
import Observation

@Observable
class AppState {
    var meetings: [Meeting]
    var activeSession: ActiveSession?
    var transcriptionService = TranscriptionService(engine: ArgmaxEngine())
    
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
    
    func endSession() async {
        transcriptionService.stopRecording()
        
        // Mock saving the session to a meeting
        if let session = activeSession {
            let transcript = await transcriptionService.generateFinalDiarizedTranscript()
            let newMeeting = Meeting(
                title: "New Recording",
                date: session.startTime,
                durationMinutes: Int(Date().timeIntervalSince(session.startTime) / 60),
                summaryPreview: transcriptionService.currentTranscript,
                summary: transcriptionService.currentTranscript,
                participantsCount: 1,
                tasks: [],
                decisions: [],
                transcript: transcript,
                audioFileURL: transcriptionService.currentAudioFileURL,
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
