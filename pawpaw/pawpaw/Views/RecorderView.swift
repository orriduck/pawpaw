import Combine
import SwiftData
import SwiftUI

struct RecorderView: View {
  @Environment(\.modelContext) var modelContext
  @Binding var showMainTab: Bool

  @State private var selectedType: ActivityType = .pee
  @State private var currentTime = Date()
  @State private var note: String = ""
  @State private var startTime = Date().addingTimeInterval(-600)  // Default 10 mins ago
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
              // Activity Selector in Glass Card
              GlassContainer {
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: 0) {  // Spacing handled by frame padding
                    ForEach(ActivityType.allCases) { type in
                      VStack(spacing: 8) {
                        ZStack {
                          Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .overlay(
                              Circle()
                                .stroke(
                                  selectedType == type ? Color.accentColor : Color.clear,
                                  lineWidth: 2.5)
                            )

                          Image(systemName: type.icon)
                            .font(.system(size: 30))
                            .foregroundStyle(.tint)
                        }

                        Text(type.rawValue)
                          .font(.system(size: 14, weight: .bold, design: .rounded))
                          .foregroundStyle(selectedType == type ? .primary : .secondary)
                      }
                      .frame(width: 90)  // Fixed smaller width for tighter spacing
                      .scaleEffect(selectedType == type ? 1.05 : 1.0)
                      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedType)
                      .onTapGesture {
                        withAnimation {
                          selectedType = type
                        }
                      }
                    }
                  }
                  .padding(.horizontal, 16)
                  .padding(.vertical, 12)
                  .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
              }
              .padding(.horizontal, 16)
              .padding(.top, 20)

              // Duration Section
              VStack(alignment: .leading, spacing: 12) {
                Text("Duration")
                  .font(.headline)
                  .foregroundStyle(.primary)

                // Quick duration buttons
                HStack(spacing: 12) {
                  ForEach([1, 15, 30], id: \.self) { minutes in
                    Button {
                      setQuickDuration(minutes: minutes)
                    } label: {
                      Text("\(minutes) min")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)  // Make buttons fill width
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                  }
                }

                // Time pickers
                VStack(spacing: 12) {
                  HStack {
                    Text("Start")
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                      .frame(width: 60, alignment: .leading)

                    DatePicker(
                      "", selection: $startTime, displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                  }

                  HStack {
                    Text("End")
                      .font(.subheadline)
                      .foregroundStyle(.secondary)
                      .frame(width: 60, alignment: .leading)

                    DatePicker(
                      "", selection: $endTime, displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                  }
                }
                .padding()
                .frame(maxWidth: .infinity)  // Fill width
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
              }
              .padding(.horizontal, 16)

              // Notes TextField
              VStack(alignment: .leading, spacing: 8) {
                Text("Notes (optional)")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)

                TextField("Add a note...", text: $note, axis: .vertical)
                  .textFieldStyle(.plain)
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(.ultraThinMaterial)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                  .lineLimit(4...8)
                  .frame(minHeight: 100)
              }
              .padding(.horizontal, 16)
              .padding(.bottom, 20)
            }
          }
          .scrollDismissesKeyboard(.interactively)

          // Fixed bottom section
          VStack(spacing: 0) {
            // Confirm Button
            Button {
              saveActivity(screenHeight: geometry.size.height)
            } label: {
              Text("Confirm Record")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.tint)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 16)

            // Swipe Down Hint
            VStack(spacing: 4) {
              Image(systemName: "chevron.down")
                .font(.body)
                .foregroundStyle(.secondary)
                .opacity(0.6)

              Text("Swipe down to cancel")
                .font(.caption)
                .foregroundStyle(.secondary)
                .opacity(0.6)
            }
            .padding(.vertical, 8)
            .padding(.bottom, 10)  // Extra bottom padding
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

  private func setQuickDuration(minutes: Int) {
    endTime = Date()
    startTime = endTime.addingTimeInterval(-Double(minutes * 60))
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

