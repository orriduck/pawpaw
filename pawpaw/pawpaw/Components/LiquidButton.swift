import SwiftUI

struct LiquidButton: View {
  var action: () -> Void
  var icon: String = "plus"

  @State private var isAnimating = false

  var body: some View {
    Button(action: {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
        isAnimating = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        isAnimating = false
        action()
      }
    }) {
      ZStack {
        // Liquid Blobs (simulated with overlapping circles/gradients for now)
        Circle()
          .fill(
            LinearGradient(
              colors: [.pink, .purple],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .frame(width: 80, height: 80)
          .scaleEffect(isAnimating ? 0.9 : 1.0)
          .shadow(color: .purple.opacity(0.4), radius: 15, x: 0, y: 10)

        Image(systemName: icon)
          .font(.system(size: 30, weight: .bold))
          .foregroundColor(.white)
          .scaleEffect(isAnimating ? 1.2 : 1.0)
      }
    }
  }
}

#Preview {
  LiquidButton(action: {})
}
