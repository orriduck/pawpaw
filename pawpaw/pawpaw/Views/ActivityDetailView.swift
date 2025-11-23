import SwiftData
import SwiftUI

struct ActivityDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ActivityManager.self) private var activityManager

  @State var activity: Activity?
  @State private var type: ActivityType
  @State private var startTime: Date
  @State private var endTime: Date
  @State private var note: String

  init(activity: Activity? = nil, type: ActivityType = .pee) {
    self._activity = State(initialValue: activity)
    self._type = State(initialValue: activity?.type ?? type)

    if let activity {
      self._startTime = State(initialValue: activity.startTime)
      self._endTime = State(initialValue: activity.endTime)
      self._note = State(initialValue: activity.note ?? "")
    } else {
      self._startTime = State(initialValue: Date())
      self._endTime = State(initialValue: Date().addingTimeInterval(600))
      self._note = State(initialValue: "")
    }
  }

  var isNew: Bool { activity == nil }

  var body: some View {
    NavigationStack {
      Form {
        Section("Activity Type") {
          Picker("Type", selection: $type) {
            ForEach(ActivityType.allCases) { type in
              Label(type.rawValue, systemImage: type.icon)
                .tag(type)
            }
          }
          .pickerStyle(.navigationLink)
        }

        Section("Time") {
          DatePicker("Start Time", selection: $startTime)
          DatePicker("End Time", selection: $endTime)

          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              Button("Last 15m") { setTimeRange(minutes: 15) }
              Button("Last 30m") { setTimeRange(minutes: 30) }
              Button("Last 40m") { setTimeRange(minutes: 40) }
            }
            .buttonStyle(.bordered)
          }
          .listRowInsets(EdgeInsets())
          .padding(.horizontal)
          .padding(.vertical, 5)
        }

        Section("Notes") {
          TextField("Add a note...", text: $note, axis: .vertical)
            .lineLimit(3...6)
        }
      }
      .navigationTitle(isNew ? "New Activity" : "Edit Activity")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            save()
            dismiss()
          }
        }
      }
      .onAppear {
        if let activity {
          type = activity.type
          startTime = activity.startTime
          endTime = activity.endTime
          note = activity.note ?? ""
        }
      }
    }
  }

  private func setTimeRange(minutes: Int) {
    let now = Date()
    endTime = now
    startTime = now.addingTimeInterval(TimeInterval(-minutes * 60))
  }

  private func save() {
    if let activity {
      // Update existing
      activity.type = type
      activity.startTime = startTime
      activity.endTime = endTime
      activity.note = note.isEmpty ? nil : note
      // In SwiftData, autosave usually handles updates if the object is managed,
      // but we can trigger a manual save on the context if needed via manager.
      // For now, assuming the object is connected to the context.
    } else {
      // Create new
      activityManager.addActivity(type: type, note: note.isEmpty ? nil : note)
      // Note: We need to manually set start/end time for new activity if they differ from init defaults
      // The addActivity method in manager is simple, let's just create it directly here or update manager.
      // Actually, let's update the manager to handle full creation or just do it here.
      // Since we don't have a complex manager method, let's just use what we have and update it,
      // OR better, let's trust the manager's addActivity but we need to pass times.
      // Let's just create a new Activity and insert it into the context via manager if possible,
      // or just use the manager's context directly if exposed.
      // For simplicity, I'll assume the manager can handle it or I'll add a more robust method later.
      // Let's just use the simple add for now and update the properties immediately after if possible,
      // but `addActivity` creates a new instance.
      // Let's modify the manager to be more flexible in a future step if needed.
      // For now, I will just use the simple add and rely on the fact that I can't easily set start/end in the simple add.
      // Wait, I should probably update the manager to accept start/end time.
      // I'll do a quick fix in the manager in the next step or just accept defaults for now.
      // Actually, I can just create the object and insert it.
      if let context = activityManager.modelContext {
        let newActivity = Activity(
          type: type, startTime: startTime, endTime: endTime, note: note.isEmpty ? nil : note)
        context.insert(newActivity)
      }
    }
  }
}

#Preview {
  ActivityDetailView(activity: nil, type: .pee)
    .modelContainer(for: Activity.self, inMemory: true)
}
