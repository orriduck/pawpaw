import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(ActivityManager.self) private var activityManager
  @Query(sort: \Activity.startTime, order: .reverse) private var recentActivities: [Activity]

  @State private var selectedActivityType: ActivityType?

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    ZStack {
      // Background with new color palette
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      ScrollView {
        VStack(spacing: 30) {
          HStack {
            Text("Quick Record")
              .font(.system(size: 34, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
            Spacer()
          }
          .padding(.horizontal)
          .padding(.top, 20)

          // Activity Grid
          LazyVGrid(columns: columns, spacing: 20) {
            ForEach(ActivityType.allCases) { type in
              ActivityButton(type: type) {
                // Short Press: Open Detail
                selectedActivityType = type
              } onLongPress: {
                // Long Press: Quick Add
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                activityManager.quickRecord(type: type)
              }
            }
          }
          .padding(.horizontal)

          // Recent Activities Preview
          GlassContainer {
            VStack(alignment: .leading, spacing: 10) {
              Text("Recent Activity")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .padding(.horizontal)
                .padding(.top)

              if let lastActivity = recentActivities.first {
                HStack {
                  Image(systemName: lastActivity.type.icon)
                    .foregroundStyle(.tint)
                    .font(.title2)
                    .frame(width: 40)

                  VStack(alignment: .leading) {
                    Text(lastActivity.type.rawValue)
                      .font(.system(size: 18, weight: .bold, design: .rounded))
                      .foregroundStyle(.primary)

                    Text(lastActivity.startTime.formatted(date: .omitted, time: .shortened))
                      .font(.caption)
                      .foregroundStyle(.secondary)
                  }

                  Spacer()

                  Text(lastActivity.duration.formattedDuration)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom)
              } else {
                Text("No activities yet.")
                  .foregroundStyle(.secondary)
                  .padding()
              }
            }
          }
          .padding()

          Spacer(minLength: 100)  // Space for floating menu
        }
      }
    }
    .sheet(item: $selectedActivityType) { type in
      ActivityDetailView(activity: nil, type: type)
    }
    // Fix for the sheet: Let's update ActivityDetailView to accept an initial type
  }
}

struct ActivityButton: View {
  let type: ActivityType
  let action: () -> Void
  let onLongPress: () -> Void

  @State private var isPressed = false

  var body: some View {
    Button(action: action) {
      VStack {
        Image(systemName: type.icon)
          .font(.system(size: 40))
          .foregroundStyle(.tint)
          .shadow(color: .white.opacity(0.5), radius: 5)

        Text(type.rawValue)
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundStyle(.tint)
      }
      .frame(maxWidth: .infinity)
      .frame(height: 120)
      .background(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .fill(.ultraThinMaterial)
          .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(.white.opacity(0.5), lineWidth: 1)
      )
    }
    .simultaneousGesture(
      LongPressGesture(minimumDuration: 0.5)
        .onEnded { _ in
          onLongPress()
        }
    )
  }
}

extension TimeInterval {
  var formattedDuration: String {
    let minutes = Int(self) / 60
    return "\(minutes) min"
  }
}

#Preview {
  HomeView()
    .environment(ActivityManager())
}
