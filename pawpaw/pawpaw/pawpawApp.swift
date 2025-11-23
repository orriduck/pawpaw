import SwiftData
import SwiftUI

@main
struct pawpawApp: App {
  @State private var persistence = PersistenceController(syncEnabled: UserDefaults.standard.bool(forKey: "iCloudSyncEnabled"))

  var body: some Scene {
    WindowGroup {
      ContentView()
        .fontDesign(.rounded)
        .environment(persistence.activityManager)
        .onReceive(NotificationCenter.default.publisher(for: .toggleCloudSync)) { output in
          if let enabled = output.object as? Bool {
            persistence.setSyncEnabled(enabled)
          }
        }
    }
    .modelContainer(persistence.container)
  }
}
