import SwiftUI

struct StaffServiceDetailView: View {
    @State private var progress = 0.3

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Service Details")
                    .font(.title)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Customer: Alex Rivera")
                    Text("Vehicle: Porsche 911")
                    Text("Service: Full Service")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(14)

                Text("Progress")
                    .font(.headline)

                ProgressView(value: progress)

                VStack(spacing: 14) {
                    Button("Start Inspection") {
                        progress = 0.5
                    }

                    Button("Start Repair") {
                        progress = 0.75
                    }

                    Button("Complete Service") {
                        progress = 1.0
                    }
                }
                .buttonStyle(.borderedProminent)

            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    StaffServiceDetailView()
}
