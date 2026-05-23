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
            HStack(spacing: 0) {
                // Custom Sidebar
                CustomSidebar(selectedTab: $selectedTab)
                    .frame(width: 200)
                    .background(Color.brandCard)
                
                Rectangle()
                    .fill(Color.brandCardBorder)
                    .frame(width: 1)
                
                // Content Pane
                HStack(spacing: 0) {
                    if selectedTab == .meetings {
                        MeetingListView(
                            meetings: appState.meetings,
                            selectedMeetingIdString: $selectedMeetingIdString
                        )
                        .frame(width: 320)
                        .background(Color.brandBg)
                        
                        Rectangle()
                            .fill(Color.brandCardBorder)
                            .frame(width: 1)
                        
                        // Detail Pane
                        ZStack {
                            Color.brandBg.ignoresSafeArea()
                            
                            if let uuid = UUID(uuidString: selectedMeetingIdString),
                               let meeting = appState.meetings.first(where: { $0.id == uuid }) {
                                MeetingDetailView(meeting: meeting)
                                    .id(uuid) // Force transition / update
                            } else {
                                Text("Select a meeting to view details.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.brandTextMuted)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedTab == .calendar {
                        Text("Calendar Placeholder")
                            .font(.system(size: 14))
                            .foregroundColor(.brandTextMuted)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.brandBg)
                    } else if selectedTab == .settings {
                        Text("Settings Placeholder")
                            .font(.system(size: 14))
                            .foregroundColor(.brandTextMuted)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.brandBg)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .ignoresSafeArea(edges: .top)
            
            // Floating Live Recording Overlay
            if appState.activeSession != nil {
                LiveRecordingView()
                    .padding()
            }
        }
        .tint(.brandAccent)
        .preferredColorScheme(.dark)
        .background(Color.brandBg)
    }
}

struct CustomSidebar: View {
    @Binding var selectedTab: NavigationTab
    @Environment(AppState.self) private var appState
    @State private var isRecordHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer().frame(height: 48)
            
            Text("Shii")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.brandTextMain)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            
            // Quick Record Button
            Button {
                if appState.activeSession == nil {
                    appState.startSession()
                }
            } label: {
                HStack(spacing: 8) {
                    if !appState.transcriptionService.isModelLoaded {
                        ProgressView(value: appState.transcriptionService.modelLoadingProgress, total: 1.0)
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                            .tint(.brandBg)
                        Text("\(Int(appState.transcriptionService.modelLoadingProgress * 100))%")
                            .font(.system(size: 13, weight: .bold))
                    } else {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Record")
                            .font(.system(size: 13, weight: .bold))
                    }
                    Spacer()
                }
                .foregroundColor(appState.activeSession != nil ? .brandTextMuted : .brandBg)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(appState.activeSession != nil ? Color.brandCardBorder : (isRecordHovered ? Color.brandAccent.opacity(0.9) : Color.brandAccent))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.bottom, 16)
            .disabled(appState.activeSession != nil)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isRecordHovered = hovering
                }
            }
            
            ForEach(NavigationTab.allCases) { tab in
                SidebarButton(tab: tab, isSelected: selectedTab == tab) {
                    selectedTab = tab
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
    }
}

struct SidebarButton: View {
    let tab: NavigationTab
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: tab.icon)
                    .font(.system(size: 14, weight: .medium))
                    .frame(width: 16)
                Text(tab.rawValue)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .foregroundColor(isSelected ? .brandBg : (isHovered ? .brandTextMain : .brandTextMuted))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.brandAccent : (isHovered ? Color.brandCardBorder.opacity(0.5) : Color.clear))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
