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
    ZStack {
      // Background
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      VStack(spacing: 0) {
        // Scrollable content
        ScrollView {
          VStack(spacing: 20) {
            // Header
            HStack {
              Text(isNew ? "New Activity" : "Edit Activity")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
              Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // Activity Form
            ActivityFormView(
              selectedType: $type,
              startTime: $startTime,
              endTime: $endTime,
              note: $note
            )
          }
        }
        .scrollDismissesKeyboard(.interactively)

        // Fixed bottom section
        VStack(spacing: 0) {
          // Action Buttons
          HStack(spacing: 12) {
            // Cancel Button
            Button {
              dismiss()
            } label: {
              Text("Cancel")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }

            // Confirm Button
            Button {
              save()
              dismiss()
            } label: {
              Text("Save")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
          }
          .padding(.horizontal, 16)
          .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemBackground))
      }
    }
    .navigationBarHidden(true)  // Hide default navigation bar to use custom header
  }

  private func save() {
    if let activity {
      // Update existing
      activity.type = type
      activity.startTime = startTime
      activity.endTime = endTime
      activity.note = note.isEmpty ? nil : note
    } else {
      // Create new
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
    .environment(ActivityManager())
}
