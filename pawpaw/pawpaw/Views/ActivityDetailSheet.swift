import SwiftData
import SwiftUI

struct ActivityDetailSheet: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) var modelContext

  let activity: Activity
  @State private var showEditSheet = false
  @State private var showDeleteAlert = false

  var body: some View {
    NavigationStack {
      ZStack {
        // System Background
        Color(UIColor.systemBackground)
          .ignoresSafeArea()

        ScrollView {
          VStack(spacing: 24) {
            // Large Icon Banner
            VStack(spacing: 12) {
              ZStack {
                Circle()
                  .fill(Color.accentColor.opacity(0.2))
                  .frame(width: 100, height: 100)

                Image(systemName: activity.type.icon)
                  .font(.system(size: 50))
                  .foregroundStyle(.tint)
              }

              Text(activity.type.rawValue)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

              Text(activity.startTime.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            // Metadata Section
            VStack(spacing: 16) {
              // Time Information
              GlassContainer {
                VStack(alignment: .leading, spacing: 12) {
                  DetailRow(
                    label: "Start Time",
                    value: activity.startTime.formatted(date: .abbreviated, time: .shortened)
                  )

                  Divider()

                  DetailRow(
                    label: "End Time",
                    value: activity.endTime.formatted(date: .abbreviated, time: .shortened)
                  )

                  Divider()

                  DetailRow(
                    label: "Duration",
                    value: activity.duration.formattedDuration
                  )
                }
                .padding()
              }

              // Notes Section
              if let note = activity.note, !note.isEmpty {
                GlassContainer {
                  VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                      .font(.system(size: 16, weight: .bold, design: .rounded))
                      .foregroundStyle(.secondary)

                    Text(note)
                      .font(.body)
                      .foregroundStyle(.primary)
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding()
                }
              }

              // Action Buttons
              VStack(spacing: 12) {
                // Edit Button
                Button {
                  showEditSheet = true
                } label: {
                  HStack {
                    Image(systemName: "pencil")
                    Text("Edit Activity")
                      .font(.system(size: 18, weight: .bold, design: .rounded))
                  }
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(.ultraThinMaterial)
                  .foregroundStyle(.primary)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Delete Button
                Button(role: .destructive) {
                  showDeleteAlert = true
                } label: {
                  HStack {
                    Image(systemName: "trash")
                    Text("Delete Activity")
                      .font(.system(size: 18, weight: .bold, design: .rounded))
                  }
                  .frame(maxWidth: .infinity)
                  .padding()
                  .background(.ultraThinMaterial)
                  .foregroundStyle(.red)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                }
              }
              .padding(.top, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.title2)
              .foregroundStyle(.secondary)
          }
        }
      }
      .sheet(isPresented: $showEditSheet) {
        ActivityDetailView(activity: activity, type: activity.type)
      }
      .alert("Delete Activity", isPresented: $showDeleteAlert) {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive) {
          deleteActivity()
        }
      } message: {
        Text("Are you sure you want to delete this activity? This action cannot be undone.")
      }
    }
  }

  private func deleteActivity() {
    modelContext.delete(activity)
    dismiss()
  }
}

struct DetailRow: View {
  let label: String
  let value: String

  var body: some View {
    HStack {
      Text(label)
        .font(.subheadline)
        .foregroundStyle(.secondary)

      Spacer()

      Text(value)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .foregroundStyle(.primary)
    }
  }
}
