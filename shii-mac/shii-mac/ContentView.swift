//
//  ContentView.swift
//  shii-mac
//
//  Created by codes on 5/22/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    @AppStorage("selectedTab") private var selectedTab: NavigationTab = .meetings
    @AppStorage("selectedMeetingIdString") private var selectedMeetingIdString: String = ""
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationSplitView {
                // Sidebar Pane
                List(NavigationTab.allCases, selection: $selectedTab) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.rawValue, systemImage: tab.icon)
                    }
                }
                .navigationTitle("Shii")
            } content: {
                // Content Pane (Middle)
                switch selectedTab {
                case .meetings:
                    MeetingListView(
                        meetings: appState.meetings,
                        selectedMeetingIdString: $selectedMeetingIdString
                    )
                    .navigationTitle("Meetings")
                case .calendar:
                    Text("Calendar Placeholder")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .navigationTitle("Calendar")
                case .settings:
                    Text("Settings Placeholder")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .navigationTitle("Settings")
                }
            } detail: {
                // Detail Pane
                if selectedTab == .meetings {
                    if let uuid = UUID(uuidString: selectedMeetingIdString),
                       let meeting = appState.meetings.first(where: { $0.id == uuid }) {
                        MeetingDetailView(meeting: meeting)
                            .id(uuid) // Force transition / update
                    } else {
                        Text("Select a meeting to view details.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Select an item.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            .navigationSplitViewStyle(.prominentDetail)
            
            // Floating Live Recording Overlay
            if appState.activeSession != nil {
                LiveRecordingView()
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
