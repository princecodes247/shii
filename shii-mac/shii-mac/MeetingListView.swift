import SwiftUI

struct MeetingListView: View {
    let meetings: [Meeting]
    @Binding var selectedMeetingIdString: String
    
    @Environment(AppState.self) private var appState
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                if meetings.isEmpty {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 60)
                        
                        Image(systemName: "waveform.path")
                            .font(.system(size: 40))
                            .foregroundColor(.brandTextMuted.opacity(0.5))
                        
                        Text("Your conversations will appear here.")
                            .font(.system(size: 14))
                            .foregroundColor(.brandTextMuted)
                        
                        Button {
                            appState.startSession()
                        } label: {
                            Text("Record your first meeting")
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        .background(Color.brandAccent)
                        .foregroundColor(Color.brandBg)
                        .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    HStack {
                        Text("Today")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.brandTextMuted)
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 4)
                    
                    ForEach(meetings) { meeting in
                        MeetingCardView(
                            meeting: meeting,
                            isSelected: selectedMeetingIdString == meeting.id.uuidString,
                            action: { selectedMeetingIdString = meeting.id.uuidString }
                        )
                    }
                }
            }
            .padding(.vertical, 12)
        }
    }
}

struct MeetingCardView: View {
    let meeting: Meeting
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(meeting.title)
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(isSelected ? .brandAccent : .brandTextMain)
                
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
                .foregroundColor(.brandTextMuted)
                
                Text(meeting.summaryPreview)
                    .font(.system(size: 12, design: .default))
                    .foregroundColor(isSelected ? .brandTextMain : .brandTextMuted)
                    .lineLimit(1)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.brandCard : (isHovered ? Color.brandCard.opacity(0.6) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.brandCardBorder : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 12)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button("Export") {}
            Button("Send to Notion") {}
            Divider()
            Button("Delete", role: .destructive) {}
        }
    }
}

#Preview {
    MeetingListView(meetings: Meeting.mockData, selectedMeetingIdString: .constant(Meeting.mockData[0].id.uuidString))
        .environment(AppState())
        .frame(width: 320)
        .background(Color.brandBg)
}
