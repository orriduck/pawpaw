import SwiftUI

struct GlassContainer<Content: View>: View {
  var cornerRadius: CGFloat = 25
  var content: Content

  init(cornerRadius: CGFloat = 25, @ViewBuilder content: () -> Content) {
    self.cornerRadius = cornerRadius
    self.content = content()
  }

  var body: some View {
    ZStack {
      // Glass Background
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)

      // Subtle Border/Highlight
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .stroke(
          LinearGradient(
            colors: [
              .white.opacity(0.5),
              .white.opacity(0.1),
              .clear,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          lineWidth: 1
        )

      content
    }
  }
}

#Preview {
  ZStack {
    Color.blue.ignoresSafeArea()
    GlassContainer {
      Text("Glass Effect")
        .padding(30)
    }
    .frame(width: 200, height: 100)
  }
}
