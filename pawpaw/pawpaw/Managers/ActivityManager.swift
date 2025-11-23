import Foundation
import SwiftData
import SwiftUI

@Observable
class ActivityManager {
  var modelContext: ModelContext?

  init(modelContext: ModelContext? = nil) {
    self.modelContext = modelContext
  }

  func addActivity(type: ActivityType, note: String? = nil) {
    guard let context = modelContext else { return }
    let newActivity = Activity(type: type, note: note)
    context.insert(newActivity)
    save()
  }

  func deleteActivity(_ activity: Activity) {
    guard let context = modelContext else { return }
    context.delete(activity)
    save()
  }

  private func save() {
    do {
      try modelContext?.save()
    } catch {
      print("Failed to save context: \(error)")
    }
  }

  // Helper for quick record
  func quickRecord(type: ActivityType) {
    addActivity(type: type)
  }
}
