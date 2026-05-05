import SwiftUI

struct ServiceTrackingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Vehicle in Service")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text("Porsche 911 Carrera S")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    InfoLine(title: "Estimated Completion", value: "Today, 04:30 PM")
                    InfoLine(title: "Service Advisor", value: "Marcus Vance")
                    InfoLine(title: "Current Progress", value: "Repairing")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                Text("Service Progress")
                    .font(.headline)

                VStack(spacing: 0) {
                    TimelineRow(title: "Received", subtitle: "Vehicle checked in and initial inspection started.", status: "Done", active: true)
                    TimelineRow(title: "Diagnosis", subtitle: "Full system diagnostics completed.", status: "Done", active: true)
                    TimelineRow(title: "Repairing", subtitle: "Technicians are replacing oil and brake components.", status: "In Progress", active: true)
                    TimelineRow(title: "Completed", subtitle: "Quality check and final wash before pickup.", status: "Pending", active: false)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Garage Log")
                        .font(.headline)

                    InfoLine(title: "Oil Filter Change", value: "Done")
                    InfoLine(title: "Brake Fluid Replacement", value: "Pending")
                    InfoLine(title: "Full Body Detailing", value: "Remaining")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                Button {
                    print("Message advisor")
                } label: {
                    Text("Message Marcus")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Service Tracking")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

struct InfoLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

struct TimelineRow: View {
    let title: String
    let subtitle: String
    let status: String
    let active: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack {
                Circle()
                    .fill(active ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 18, height: 18)

                Rectangle()
                    .fill(Color.gray.opacity(0.25))
                    .frame(width: 2, height: 60)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title)
                        .font(.headline)

                    Spacer()

                    Text(status)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(active ? .blue : .gray)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(14)
        }
    }
}

#Preview {
    ServiceTrackingView()
}
