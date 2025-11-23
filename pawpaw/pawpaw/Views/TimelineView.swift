import SwiftData
import SwiftUI

struct TimelineView: View {
  @Environment(\.modelContext) var modelContext
  @Query(sort: \Activity.startTime, order: .reverse) private var activities: [Activity]
  @State private var selectedActivity: Activity?

  var body: some View {
    NavigationStack {
      ZStack {
        // Light background
        Color(UIColor.systemBackground)
          .ignoresSafeArea()

        ScrollView {
          VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
              HStack {
                Text("All Activities")
                  .font(.system(size: 32, weight: .bold, design: .rounded))
                  .foregroundStyle(.primary)

                Spacer()
              }

              Text("\(activities.count) activities")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 20)

            // All activities in one card
            if !activities.isEmpty {
              GlassContainer {
                VStack(spacing: 0) {
                  ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    SwipeableActivityRow(activity: activity) {
                      selectedActivity = activity
                    } onEdit: {
                      selectedActivity = activity
                    } onDelete: {
                      deleteActivity(activity)  // This function needs to be implemented in TimelineView
                    }

                    if index < activities.count - 1 {
                      Divider()
                        .padding(.leading, 82)  // Align with text (50 icon + 16 padding + 16 spacing)
                    }
                  }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
              }
              .padding(.horizontal)
            } else {
              VStack(spacing: 12) {
                Image(systemName: "pawprint.fill")
                  .font(.system(size: 48))
                  .foregroundStyle(.secondary)

                Text("No activities yet")
                  .font(.system(size: 20, weight: .bold, design: .rounded))
                  .foregroundStyle(.secondary)

                Text("Start recording your puppy's activities!")
                  .font(.subheadline)
                  .foregroundStyle(.tertiary)
              }
              .frame(maxWidth: .infinity)
              .padding(.top, 60)
            }
          }
          .padding(.bottom, 20)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .sheet(item: $selectedActivity) { activity in
        ActivityDetailSheet(activity: activity)
      }
    }
  }
  private func deleteActivity(_ activity: Activity) {
    withAnimation {
      modelContext.delete(activity)
    }
  }
}

struct SwipeableActivityRow: View {
  let activity: Activity
  let onTap: () -> Void
  let onEdit: () -> Void
  let onDelete: () -> Void

  @State private var offset: CGFloat = 0
  @State private var isSwiped = false

  // Constants
  private let buttonWidth: CGFloat = 70
  private let swipeThreshold: CGFloat = 40

  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        // Content Layer
        HStack(spacing: 16) {
          // Circular Icon
          ZStack {
            Circle()
              .fill(.tint)
              .frame(width: 50, height: 50)

            Image(systemName: activity.type.icon)
              .font(.system(size: 24))
              .foregroundStyle(.white)
          }

          // Activity Info
          VStack(alignment: .leading, spacing: 4) {
            Text(activity.type.rawValue)
              .font(.system(size: 18, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)

            HStack(spacing: 4) {
              if let note = activity.note, !note.isEmpty {
                Text(note)
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .lineLimit(1)
                Text("—")
                  .font(.caption)
                  .foregroundStyle(.tertiary)
              }
              Text(activity.startTime.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }

          Spacer()

          // Duration and Chevron
          HStack(spacing: 4) {
            Text(activity.duration.formattedDuration)
              .font(.system(size: 16, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)

            Image(systemName: "chevron.right")
              .font(.system(size: 12, weight: .semibold))
              .foregroundStyle(.tertiary)
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: geometry.size.width)  // Ensure full width
        .contentShape(Rectangle())
        .onTapGesture {
          if offset == 0 {
            onTap()
          } else {
            withAnimation {
              offset = 0
              isSwiped = false
            }
          }
        }

        // Action Buttons Layer (Side-by-side)
        HStack(spacing: 0) {
          // Edit Button
          Button(action: {
            withAnimation {
              offset = 0
              isSwiped = false
              onEdit()
            }
          }) {
            ZStack {
              Color.gray.opacity(0.2)
              Image(systemName: "pencil")
                .font(.title3)
                .foregroundStyle(.primary)
            }
            .frame(width: buttonWidth)
            .frame(maxHeight: .infinity)
          }

          // Delete Button
          Button(action: {
            withAnimation {
              offset = 0
              isSwiped = false
              onDelete()
            }
          }) {
            ZStack {
              Color.red
              Image(systemName: "trash.fill")
                .font(.title3)
                .foregroundStyle(.white)
            }
            .frame(width: buttonWidth)
            .frame(maxHeight: .infinity)
          }
        }
      }
      .offset(x: offset)
      .gesture(
        DragGesture()
          .onChanged { gesture in
            // Only allow left swipe
            if gesture.translation.width < 0 {
              offset = gesture.translation.width
            } else if isSwiped {
              // If already swiped, allow dragging back to right
              offset = max(-buttonWidth * 2 + gesture.translation.width, -buttonWidth * 2)
            }
          }
          .onEnded { gesture in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
              if gesture.translation.width < -swipeThreshold {
                offset = -buttonWidth * 2  // Show both buttons
                isSwiped = true
              } else {
                offset = 0
                isSwiped = false
              }
            }
          }
      )
    }
    .frame(height: 74)  // Fixed height for the row to allow GeometryReader to work
  }
}

#Preview {
  TimelineView()
    .modelContainer(for: Activity.self, inMemory: true)
}
