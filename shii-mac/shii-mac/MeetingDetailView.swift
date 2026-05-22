import SwiftUI

struct MeetingDetailView: View {
    let meeting: Meeting
    @State private var showFullTranscript = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(meeting.title)
                        .font(.system(size: 28, weight: .semibold, design: .default))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Text(meeting.date.timeString())
                        Text("•")
                        Text("Duration: \(meeting.durationMinutes) min")
                        Text("•")
                        Text("Participants: \(meeting.participantsCount)")
                    }
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Section 1: AI Summary (Hero Block)
                VStack(alignment: .leading, spacing: 12) {
                    Text(meeting.summary)
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.05))
                )
                
                // Section 2: Key decisions
                if !meeting.decisions.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "DECISIONS")
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(meeting.decisions) { decision in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 16))
                                        .padding(.top, 2)
                                    
                                    Text(decision.description)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }
                
                // Section 3: Action Items
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "TASKS")
                    
                    if meeting.tasks.isEmpty {
                        Text("No action items detected.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(meeting.tasks) { task in
                                HStack(alignment: .center, spacing: 12) {
                                    Circle()
                                        .stroke(Color.secondary.opacity(0.5), lineWidth: 1.5)
                                        .frame(width: 16, height: 16)
                                    
                                    HStack(spacing: 8) {
                                        Text(task.assignee)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.secondary.opacity(0.1))
                                            .cornerRadius(6)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 10, weight: .semibold))
                                            .foregroundColor(.secondary)
                                        
                                        Text(task.description)
                                            .font(.system(size: 15))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    if let dueDate = task.dueDate {
                                        Text("Due: \(dueDate)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                
                // Section 4: Timeline / Transcript
                if !meeting.transcript.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "TIMELINE")
                        
                        VStack(alignment: .leading, spacing: 20) {
                            let itemsToShow = showFullTranscript ? meeting.transcript : Array(meeting.transcript.prefix(2))
                            
                            ForEach(itemsToShow) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 8) {
                                        Text(item.timestamp)
                                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                                            .foregroundColor(.secondary)
                                        
                                        Text(item.speaker)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Text(item.text)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .lineSpacing(3)
                                }
                                .padding(.leading, 12)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.2))
                                        .frame(width: 2)
                                        .padding(.leading, -12),
                                    alignment: .leading
                                )
                            }
                        }
                        
                        if meeting.transcript.count > 2 {
                            Button(action: {
                                withAnimation {
                                    showFullTranscript.toggle()
                                }
                            }) {
                                Text(showFullTranscript ? "Collapse transcript" : "View full transcript")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 8)
                        }
                    }
                }
                
                Spacer().frame(height: 60)
            }
            .padding(.horizontal, 40)
            .frame(maxWidth: 800, alignment: .leading)
        }
        .background(Color(NSColor.textBackgroundColor))
    }
}

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .semibold, design: .default))
                .foregroundColor(.secondary)
                .tracking(1.0)
            
            Divider()
        }
    }
}

#Preview {
    MeetingDetailView(meeting: Meeting.mockData[0])
        .frame(width: 600, height: 800)
}
