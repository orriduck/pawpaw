import Foundation
import Observation
import SwiftData

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
    let modelConfiguration: ModelConfiguration

    // Ensure the Application Support directory exists
    let fileManager = FileManager.default
    let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
      .first!

    do {
      try fileManager.createDirectory(
        at: appSupportURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
      print("Error creating Application Support directory: \(error)")
    }

    let storeURL = appSupportURL.appendingPathComponent("pawpaw.store")

    if syncEnabled {
      modelConfiguration = ModelConfiguration(
        schema: schema, url: storeURL, cloudKitDatabase: .automatic)
      print("PersistenceController: CloudKit sync enabled")
    } else {
      modelConfiguration = ModelConfiguration(
        schema: schema, url: storeURL, cloudKitDatabase: .none)
    }

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
