import Foundation
import SwiftData
import Observation

@Observable
class PersistenceController {
  var container: ModelContainer
  var activityManager: ActivityManager

  init(syncEnabled: Bool = true) {
    let container = PersistenceController.buildContainer(syncEnabled: syncEnabled)
    self.container = container
    self.activityManager = ActivityManager(modelContext: container.mainContext)
  }

  func setSyncEnabled(_ enabled: Bool) {
    if !enabled {
      // Best-effort purge of CloudKit data so user’s iCloud is cleaned up when they turn sync off
      purgeCloudStore()
    }

    // Rebuild container with/without CloudKit
    self.container = PersistenceController.buildContainer(syncEnabled: enabled)

    // Update ActivityManager to use the new context
    self.activityManager.modelContext = container.mainContext

    // Persist preference
    UserDefaults.standard.set(enabled, forKey: "iCloudSyncEnabled")
  }

  private static func buildContainer(syncEnabled: Bool) -> ModelContainer {
    let schema = Schema([Activity.self])
    let configuration: ModelConfiguration
    if syncEnabled {
      configuration = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
    } else {
      configuration = ModelConfiguration(schema: schema)
    }

    do {
      return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }

  private func purgeCloudStore() {
    let schema = Schema([Activity.self])
    let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
    do {
      let cloudContainer = try ModelContainer(for: schema, configurations: [config])
      let context = cloudContainer.mainContext
      try context.delete(model: Activity.self)
      try context.save()
    } catch {
      print("Failed to purge CloudKit store: \(error)")
    }
  }
}
