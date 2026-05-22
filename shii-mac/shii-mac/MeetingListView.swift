import SwiftUI

struct MeetingListView: View {
    let meetings: [Meeting]
    @Binding var selectedMeetingIdString: String
    
    @Environment(AppState.self) private var appState
    
    private var selectedMeetingId: Binding<UUID?> {
        Binding(
            get: { UUID(uuidString: selectedMeetingIdString) },
            set: { selectedMeetingIdString = $0?.uuidString ?? "" }
        )
    }
    
    var body: some View {
        List(selection: selectedMeetingId) {
            if meetings.isEmpty {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    
                    Image(systemName: "waveform.path")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text("Your conversations will appear here.")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Button {
                        appState.startSession()
                    } label: {
                        Text("Record your first meeting")
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                Section(header: Text("Today").font(.system(size: 11, weight: .semibold)).foregroundColor(.secondary)) {
                    ForEach(meetings) { meeting in
                        MeetingListRow(meeting: meeting)
                            .tag(meeting.id)
                            .padding(.vertical, 4)
                            .contextMenu {
                                Button("Export") {}
                                Button("Send to Notion") {}
                                Divider()
                                Button("Delete", role: .destructive) {}
                            }
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }
}

struct MeetingListRow: View {
    let meeting: Meeting
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meeting.title)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(.primary)
            
            HStack(spacing: 6) {
                Text(meeting.date.relativeString())
                
                if !meeting.tasks.isEmpty || !meeting.decisions.isEmpty {
                    Text("·")
                    if !meeting.tasks.isEmpty {
                        Text("\(meeting.tasks.count) tasks")
                    }
                    if !meeting.decisions.isEmpty {
                        if !meeting.tasks.isEmpty {
                            Text("·")
                        }
                        Text("\(meeting.decisions.count) decisions")
                    }
                }
            }
            .font(.system(size: 11, design: .default))
            .foregroundColor(.secondary)
            
            Text(meeting.summaryPreview)
                .font(.system(size: 12, design: .default))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    MeetingListView(meetings: Meeting.mockData, selectedMeetingIdString: .constant(Meeting.mockData[0].id.uuidString))
        .environment(AppState())
        .frame(width: 300)
}
