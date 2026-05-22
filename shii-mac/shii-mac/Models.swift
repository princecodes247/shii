import Foundation

struct Meeting: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let durationMinutes: Int
    let summaryPreview: String
    
    let summary: String
    let participantsCount: Int
    let tasks: [TaskItem]
    let decisions: [DecisionItem]
    let transcript: [TranscriptItem]
    
    let isImportant: Bool
}

struct TaskItem: Identifiable, Hashable {
    let id = UUID()
    let assignee: String
    let description: String
    let dueDate: String?
}

struct DecisionItem: Identifiable, Hashable {
    let id = UUID()
    let description: String
}

struct TranscriptItem: Identifiable, Hashable {
    let id = UUID()
    let timestamp: String
    let speaker: String
    let text: String
}

extension Meeting {
    static let mockData: [Meeting] = [
        Meeting(
            title: "Product sync",
            date: Date().addingTimeInterval(-180), // 3 min ago
            durationMinutes: 42,
            summaryPreview: "Aligned on Q1 roadmap and assigned onboarding redesign.",
            summary: "The team aligned on Q1 roadmap priorities, agreed to delay feature X, and assigned ownership for onboarding redesign.",
            participantsCount: 3,
            tasks: [
                TaskItem(assignee: "John", description: "Finalize API spec", dueDate: "Friday"),
                TaskItem(assignee: "You", description: "Draft onboarding flow redesign", dueDate: nil),
                TaskItem(assignee: "Sarah", description: "Review Stripe integration", dueDate: nil)
            ],
            decisions: [
                DecisionItem(description: "Delay onboarding redesign to Q2"),
                DecisionItem(description: "Ship billing API before UI revamp"),
                DecisionItem(description: "Use Stripe instead of custom billing")
            ],
            transcript: [
                TranscriptItem(timestamp: "12:03", speaker: "Alex", text: "We should probably delay onboarding until we sort out the API."),
                TranscriptItem(timestamp: "12:05", speaker: "You", text: "Yeah I agree, but let's make sure billing is done first. Are we still using Stripe?"),
                TranscriptItem(timestamp: "12:06", speaker: "Sarah", text: "Yes, Stripe is the plan. I will review the integration.")
            ],
            isImportant: true
        ),
        Meeting(
            title: "Client call",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, // Yesterday
            durationMinutes: 28,
            summaryPreview: "Discussed deliverables for next month.",
            summary: "Reviewed the latest wireframes with the client. They requested a few minor adjustments to the color palette.",
            participantsCount: 2,
            tasks: [
                TaskItem(assignee: "You", description: "Update wireframe colors", dueDate: "Tomorrow")
            ],
            decisions: [
                DecisionItem(description: "Approved layout direction")
            ],
            transcript: [],
            isImportant: false
        ),
        Meeting(
            title: "Weekly standup",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, // 2 days ago
            durationMinutes: 15,
            summaryPreview: "Routine updates from the team.",
            summary: "Everyone is on track. No major blockers.",
            participantsCount: 5,
            tasks: [],
            decisions: [],
            transcript: [],
            isImportant: false
        )
    ]
}

extension Date {
    func relativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func timeString() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
