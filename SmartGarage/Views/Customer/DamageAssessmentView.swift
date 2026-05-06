import SwiftUI

struct DamageAssessmentView: View {
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Damage Assessment")
                    .font(.title)
                    .fontWeight(.bold)

                
                Text("Upload vehicle photos and get instant damage analysis.")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 22) {
                Image(systemName: "camera.badge.ellipsis")
                    .font(.system(size: 42))
                    .foregroundColor(.blue)
                    .frame(width: 90, height: 90)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(25)

                Text("Upload Vehicle Photos")
                    .font(.title3)
                    .fontWeight(.bold)

                Text("Capture the damage area clearly for better assessment accuracy.")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    PhotoBox(title: "Front View")
                    PhotoBox(title: "Rear View")
                    PhotoBox(title: "Left View")
                    PhotoBox(title: "Right View")
                }

                Button {
                    showResult = true
                } label: {
                    Label("Scan for Damage", systemImage: "viewfinder")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(24)

            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .navigationDestination(isPresented: $showResult) {
            DamageResultView()
        }
    }
}

struct PhotoBox: View {
    let title: String

    var body: some View {
        VStack {
            Image(systemName: "car.fill")
                .foregroundColor(.gray)

            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 95)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
    }
}

#Preview {
    NavigationStack {
        DamageAssessmentView()
    }
}
