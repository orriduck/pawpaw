import SwiftUI

struct ActivityFormView: View {
  @Binding var selectedType: ActivityType
  @Binding var startTime: Date
  @Binding var endTime: Date
  @Binding var note: String

  var body: some View {
    VStack(spacing: 20) {
      // Activity Selector in Glass Card
      GlassContainer {
        ScrollViewReader { proxy in
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
                .animation(
                  .spring(response: 0.4, dampingFraction: 0.7), value: selectedType
                )
                .onTapGesture {
                  withAnimation {
                    selectedType = type
                  }
                }
                .id(type)
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.viewAligned)
          .onAppear {
            // Scroll to current type with center anchor
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              withAnimation {
                proxy.scrollTo(selectedType, anchor: .center)
              }
            }
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 20)

      // Duration Section
      VStack(alignment: .leading, spacing: 12) {
        Text("Duration")
          .font(.headline)
          .foregroundStyle(.primary)

        Text("Changing duration will adjust the start time")
          .font(.subheadline)
          .foregroundStyle(.secondary)

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

  private func setQuickDuration(minutes: Int) {
    startTime = endTime.addingTimeInterval(-Double(minutes * 60))
  }
}

#Preview {
  ZStack {
    Color.gray.opacity(0.2).ignoresSafeArea()
    ScrollView {
      ActivityFormView(
        selectedType: .constant(.pee),
        startTime: .constant(Date()),
        endTime: .constant(Date()),
        note: .constant("")
      )
    }
  }
}
