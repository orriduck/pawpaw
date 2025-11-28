import Combine
import SwiftData
import SwiftUI

struct RecorderView: View {
  @Environment(\.modelContext) var modelContext
  @Binding var showMainTab: Bool

  @State private var selectedType: ActivityType = .pee
  @State private var currentTime = Date()
  @State private var note: String = ""
  @State private var startTime = Date().addingTimeInterval(-60)  // Start with 1 min for pee
  @State private var endTime = Date()
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  // For swipe up gesture
  @State private var offset: CGFloat = 0

  var body: some View {
    GeometryReader { geometry in
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
                Text("Record Activity")
                  .font(.system(size: 34, weight: .bold, design: .rounded))
                  .foregroundStyle(.primary)
                Spacer()
              }
              .padding(.horizontal)
              .padding(.top, 20)

              // Activity Form
              ActivityFormView(
                selectedType: $selectedType,
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
                cancelActivity(screenHeight: geometry.size.height)
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
                saveActivity(screenHeight: geometry.size.height)
              } label: {
                Text("Confirm")
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
      .offset(y: offset)
      .simultaneousGesture(  // Use simultaneousGesture to allow scrolling and swiping
        DragGesture()
          .onChanged { gesture in
            if gesture.translation.height > 0 {
              offset = gesture.translation.height
            }
          }
          .onEnded { gesture in
            if gesture.translation.height > 100 {
              // Swiped down enough to dismiss
              withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = geometry.size.height
              }
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showMainTab = true
              }
            } else {
              // Reset
              withAnimation(.spring) {
                offset = 0
              }
            }
          }
      )
      .onReceive(timer) { input in
        currentTime = input
        // Auto-update end time if it's in the future
        if endTime > currentTime {
          endTime = currentTime
        }
      }
    }
  }

  private func defaultDuration(for type: ActivityType) -> Int {
    switch type {
    case .pee, .poo:
      return 1
    case .eat:
      return 15
    case .play:
      return 30
    default:
      return 10
    }
  }

  private func setQuickDuration(minutes: Int) {
    startTime = endTime.addingTimeInterval(-Double(minutes * 60))
  }

  private func cancelActivity(screenHeight: CGFloat) {
    // Animate out and dismiss without saving
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
      offset = screenHeight
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      showMainTab = true
    }
  }

  private func saveActivity(screenHeight: CGFloat) {
    let activity = Activity(type: selectedType, startTime: startTime, endTime: endTime)
    if !note.isEmpty {
      activity.note = note
    }
    modelContext.insert(activity)

    // Animate out and switch to main tab
    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
      offset = -screenHeight
    }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      showMainTab = true
    }
  }
}

#Preview {
  RecorderView(showMainTab: .constant(false))
    .modelContainer(for: Activity.self, inMemory: true)
}
