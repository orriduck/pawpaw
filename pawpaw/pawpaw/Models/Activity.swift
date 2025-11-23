import Foundation
import SwiftData

enum ActivityType: String, Codable, CaseIterable, Identifiable {
  case pee = "Pee"
  case poo = "Poo"
  case eat = "Eat"
  case play = "Play"
  case walk = "Walk"
  case other = "Other"

  var id: String { self.rawValue }

  var icon: String {
    switch self {
    case .pee: return "drop.fill"
    case .poo: return "toilet.fill"
    case .eat: return "fork.knife"
    case .play: return "figure.play"
    case .walk: return "figure.walk"
    case .other: return "pawprint.fill"
    }
  }
  var displayName: String {
    switch self {
    case .pee: return "Pee"
    case .poo: return "Poop"
    default: return self.rawValue
    }
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)

    // Handle legacy "Potty" value by mapping it to .pee (or .poo)
    if rawValue == "Potty" {
      self = .pee
    } else if let type = ActivityType(rawValue: rawValue) {
      self = type
    } else {
      // Fallback for any other unknown values
      self = .other
    }
  }
}

@Model
final class Activity {
  var id: UUID
  var type: ActivityType
  var startTime: Date
  var endTime: Date
  var note: String?

  init(type: ActivityType, startTime: Date = Date(), endTime: Date? = nil, note: String? = nil) {
    self.id = UUID()
    self.type = type
    self.startTime = startTime
    // Default duration is 10 minutes if not specified
    self.endTime = endTime ?? startTime.addingTimeInterval(600)
    self.note = note
  }

  var duration: TimeInterval {
    endTime.timeIntervalSince(startTime)
  }
}

