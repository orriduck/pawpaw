import SwiftUI

struct ContentView: View {
  @State private var showRecorder = false
  @State private var searchText = ""

  enum MainTab: Hashable { case statistics, timeline, settings, add }
  @State private var selectedTab: MainTab = .statistics
  @State private var lastNonAddTab: MainTab = .statistics

  var body: some View {
  TabView(selection: $selectedTab) {
    NavigationStack { StatisticsView() }
      .tabItem {
        Label("Statistics", systemImage: "chart.xyaxis.line")
      }
      .tag(MainTab.statistics)

    NavigationStack { TimelineView() }
      .tabItem {
        Label("Timeline", systemImage: "clock.fill")
      }
      .tag(MainTab.timeline)

    NavigationStack { SettingsView() }
      .tabItem {
        Label("Settings", systemImage: "gearshape.fill")
      }
      .tag(MainTab.settings)

    Color.clear
      .tabItem {
        Label("Add", systemImage: "plus")
      }
      .tag(MainTab.add)
  }
    .labelStyle(.titleAndIcon)
    .onChange(of: selectedTab) { newValue in
      if newValue == .add {
        showRecorder = true
        // Revert selection to the last non-Add tab so the app stays on the previous tab
        selectedTab = lastNonAddTab
      } else {
        lastNonAddTab = newValue
      }
    }
    .sheet(isPresented: $showRecorder) {
      RecorderView(
        showMainTab: Binding(
          get: { !showRecorder },
          set: { showRecorder = !$0 }
        )
      )
    }
  }
}

#Preview {
  ContentView()
    .environment(ActivityManager())
}
