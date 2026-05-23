import Foundation
import SwiftUI

enum NavigationTab: String, CaseIterable, Identifiable {
    case meetings = "Meetings"
    case calendar = "Calendar"
    case settings = "Settings"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .meetings: return "waveform.path"
        case .calendar: return "calendar"
        case .settings: return "gearshape"
        }
    }
}
