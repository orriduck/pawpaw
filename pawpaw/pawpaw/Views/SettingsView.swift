import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.modelContext) var modelContext
  @Query private var activities: [Activity]
  @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true
  @State private var showDeleteAlert = false
  @State private var showDisableICloudAlert = false
  @State private var pendingDisableICloud = false
  @Environment(ActivityManager.self) private var activityManager

  var body: some View {
    ZStack {
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          HStack {
            Text("Settings")
              .font(.system(size: 34, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
            Spacer()
          }
          .padding(.horizontal)
          .padding(.top, 20)

          // About Me
          VStack(alignment: .leading, spacing: 12) {
            Text("About Me")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .padding(.horizontal)

            GlassContainer {
              VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                  Image(systemName: "pawprint.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.tint)

                  VStack(alignment: .leading, spacing: 4) {
                    Text("PawPaw Tracker")
                      .font(.system(size: 20, weight: .bold, design: .rounded))
                      .foregroundStyle(.primary)
                    Text("Version 1.0.0")
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }
                }

                Divider()

                Text(
                  "A cute app to track your puppy's daily activities and keep them healthy and happy!"
                )
                .font(.body)
                .foregroundStyle(.secondary)
              }
              .padding()
            }
            .padding(.horizontal)
          }

          // iCloud Sync
          VStack(alignment: .leading, spacing: 12) {
            Text("Data Sync")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .padding(.horizontal)

            GlassContainer {
              VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $iCloudSyncEnabled) {
                  HStack {
                    Image(systemName: "icloud.fill")
                      .foregroundStyle(.blue)
                    Text("Sync to iCloud")
                      .font(.system(size: 18, weight: .bold, design: .rounded))
                  }
                }
                .onChange(of: iCloudSyncEnabled) { newValue in
                  if newValue == false {
                    if pendingDisableICloud {
                      // Confirmed by user
                      pendingDisableICloud = false
                      NotificationCenter.default.post(name: .toggleCloudSync, object: false)
                    } else {
                      // Ask for confirmation and revert toggle until confirmed
                      pendingDisableICloud = true
                      showDisableICloudAlert = true
                      iCloudSyncEnabled = true
                    }
                  } else {
                    NotificationCenter.default.post(name: .toggleCloudSync, object: true)
                  }
                }

                Text("When enabled, your activities sync with iCloud and are available on your devices. Turning it off switches to local-only storage and removes your data from iCloud. Your local data remains on this device.")
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                  .fixedSize(horizontal: false, vertical: true)
              }
              .padding()
            }
            .padding(.horizontal)
          }

          // Data Management
          VStack(alignment: .leading, spacing: 12) {
            Text("Data Management")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .padding(.horizontal)

            GlassContainer {
              VStack(alignment: .leading, spacing: 8) {
                Button(role: .destructive) {
                  showDeleteAlert = true
                } label: {
                  HStack {
                    Image(systemName: "trash.fill")
                    Text("Remove All Data")
                      .font(.system(size: 18, weight: .bold, design: .rounded))
                    Spacer()
                  }
                  .foregroundStyle(.red)
                  .padding()
                }

                Text("Deletes all activities from this device. If Sync to iCloud is enabled, your data will also be removed from iCloud and other devices. This action cannot be undone.")
                  .font(.footnote)
                  .foregroundStyle(.secondary)
                  .padding(.horizontal)
                  .padding(.bottom, 8)
              }
            }
            .padding(.horizontal)
          }
        }
        .padding(.bottom, 40)
      }
    }
    .alert("Turn Off iCloud Sync?", isPresented: $showDisableICloudAlert) {
      Button("Cancel", role: .cancel) {
        pendingDisableICloud = false
        iCloudSyncEnabled = true
      }
      Button("Turn Off", role: .destructive) {
        // Proceed to disable; onChange will post notification
        iCloudSyncEnabled = false
      }
    } message: {
      Text("Turning off iCloud Sync will stop syncing and delete your data from iCloud. Your local data remains on this device.")
    }
    .alert("Remove All Data", isPresented: $showDeleteAlert) {
      Button("Cancel", role: .cancel) {}
      Button("Remove All", role: .destructive) {
        deleteAllData()
      }
    } message: {
      Text("Are you sure you want to remove all recorded activities? This action cannot be undone.")
    }
  }

  private func deleteAllData() {
    do {
      try modelContext.delete(model: Activity.self)
    } catch {
      print("Failed to delete all data: \(error)")
    }
  }
}

#Preview {
  SettingsView()
    .modelContainer(for: Activity.self, inMemory: true)
}

extension Notification.Name {
  static let toggleCloudSync = Notification.Name("toggleCloudSync")
}
