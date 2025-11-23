import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
  @Query(sort: \Activity.startTime, order: .reverse) private var activities: [Activity]
  @State private var selectedRange: StatsRange = .today

  var body: some View {
    ZStack {
      // Background
      Color(UIColor.systemBackground)
        .ignoresSafeArea()

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          HStack {
            Text("Statistics")
              .font(.system(size: 34, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
            Spacer()
          }
          .padding(.horizontal)
          .padding(.top, 20)

          // Typical Time Cards
          VStack(alignment: .leading, spacing: 12) {
            Text("Typical Times")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .padding(.horizontal)

            GlassContainer {
              VStack(alignment: .leading, spacing: 16) {
                TypicalTimeRow(title: "Pee", color: .cyan, type: .pee, activities: activities)
                TypicalTimeRow(title: "Poo", color: .brown, type: .poo, activities: activities)
              }
              .padding()
            }
            .padding(.horizontal)
          }

          // Totals by Category with filter
          VStack(alignment: .leading, spacing: 12) {
            Text("Totals by Category")
              .font(.system(size: 20, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .padding(.horizontal)

            GlassContainer {
              VStack(alignment: .leading, spacing: 12) {
                Picker("Range", selection: $selectedRange) {
                  Text("Today").tag(StatsRange.today)
                  Text("Last 7 Days").tag(StatsRange.last7)
                  Text("All Time").tag(StatsRange.all)
                }
                .pickerStyle(.segmented)

                TotalsChart(activities: activities, range: selectedRange)
              }
              .padding()
            }
            .padding(.horizontal)
          }

          Spacer(minLength: 60)
        }
      }
    }
  }
}

enum StatsRange: String, CaseIterable, Identifiable {
  case today
  case last7
  case all
  var id: String { rawValue }
}

struct TypicalTimeRow: View {
  let title: String
  let color: Color
  let type: ActivityType
  let activities: [Activity]

  private var formalTitle: String { type.displayName }

  private var countsPerHour: [Int] {
    var counts = Array(repeating: 0, count: 24)
    for activity in activities where activity.type == type {
      let hour = Calendar.current.component(.hour, from: activity.startTime)
      counts[hour] += 1
    }
    return counts
  }

  private var maxCount: Int {
    max(countsPerHour.max() ?? 0, 1)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        Image(systemName: type.icon)
          .foregroundStyle(color)
        Text(formalTitle)
          .font(.system(size: 16, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)
      }

      HStack(spacing: 2) {
        ForEach(0..<24, id: \.self) { hour in
          RoundedRectangle(cornerRadius: 2)
            .fill(color.opacity(opacity(for: countsPerHour[hour], max: maxCount)))
            .frame(height: 16)
            .accessibilityLabel(Text("\(title) at \(hour)h: \(countsPerHour[hour])"))
        }
      }

      HStack {
        Text("0h")
        Spacer()
        Text("12h")
        Spacer()
        Text("23h")
      }
      .font(.caption2)
      .foregroundStyle(.secondary)
    }
  }

  private func opacity(for count: Int, max: Int) -> Double {
    // Base 0.15 opacity for zero counts; scale up to 1.0 for max
    let ratio = max == 0 ? 0.0 : Double(count) / Double(max)
    return 0.15 + ratio * 0.85
  }
}

struct TotalsChart: View {
  let activities: [Activity]
  let range: StatsRange

  private var filtered: [Activity] {
    let cal = Calendar.current
    switch range {
    case .today:
      let start = cal.startOfDay(for: Date())
      return activities.filter { $0.startTime >= start }
    case .last7:
      let start = cal.date(byAdding: .day, value: -6, to: cal.startOfDay(for: Date())) ?? Date()
      return activities.filter { $0.startTime >= start }
    case .all:
      return activities
    }
  }

  private var counts: [(type: ActivityType, count: Int)] {
    ActivityType.allCases.map { type in
      (type: type, count: filtered.filter { $0.type == type }.count)
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      ForEach(Array(ActivityType.allCases.enumerated()), id: \.element.id) { index, type in
        let count = counts.first(where: { $0.type == type })?.count ?? 0
        HStack(alignment: .center) {
          Label {
            Text(type.displayName)
              .font(.system(size: 16, weight: .semibold, design: .rounded))
              .foregroundStyle(.primary)
          } icon: {
            Image(systemName: type.icon)
              .foregroundStyle(.tint)
          }
          .labelStyle(.titleAndIcon)

          Spacer()

          Text("\(count)")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
        }
        .padding(.vertical, 8)

        if index < ActivityType.allCases.count - 1 {
          Divider()
        }
      }
    }
  }
}

#Preview {
  StatisticsView()
    .modelContainer(for: Activity.self, inMemory: true)
}

