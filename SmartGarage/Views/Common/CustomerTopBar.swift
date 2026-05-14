import SwiftUI

struct CustomerTopBar<Trailing: View>: View {
    let onBack: () -> Void
    var showsBackButton = true
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            if showsBackButton {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            Text("SmartGarage")
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Spacer()

            trailing()
        }
    }
}
