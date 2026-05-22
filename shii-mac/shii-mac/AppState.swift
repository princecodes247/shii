import Foundation
import SwiftUI
import Observation

@Observable
class AppState {
    var meetings: [Meeting]
    var activeSession: ActiveSession?
    
    init(meetings: [Meeting] = Meeting.mockData) {
        self.meetings = meetings
    }
    
    func startSession() {
        activeSession = ActiveSession(startTime: Date())
    }
    
    func endSession() {
        activeSession = nil
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
