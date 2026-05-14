import SwiftUI


struct ServiceTrackingView: View {
    let booking: Booking

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                Text("Vehicle in Service")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Text(booking.vehicleName)
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    InfoLine(title: "Service Type", value: booking.serviceType)
                    InfoLine(title: "Booking Date", value: booking.bookingDate)
                    InfoLine(title: "Time Slot", value: booking.timeSlot)
                    InfoLine(title: "Current Status", value: booking.status)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                Text("Service Progress")
                    .font(.headline)

                VStack(spacing: 0) {
                    TimelineRow(
                        title: "Booking Received",
                        subtitle: "Your booking has been received by the garage.",
                        status: statusReached("Pending") ? "Done" : "Pending",
                        active: statusReached("Pending")
                    )

                    TimelineRow(
                        title: "Inspection Started",
                        subtitle: "Technician has started inspecting your vehicle.",
                        status: statusReached("Inspection Started") ? "Done" : "Pending",
                        active: statusReached("Inspection Started")
                    )

                    TimelineRow(
                        title: "Repair In Progress",
                        subtitle: "Technicians are working on your selected service.",
                        status: statusReached("Repair In Progress") ? "In Progress" : "Pending",
                        active: statusReached("Repair In Progress")
                    )

                    TimelineRow(
                        title: "Completed",
                        subtitle: "Service has been completed and vehicle is ready.",
                        status: statusReached("Completed") ? "Done" : "Pending",
                        active: statusReached("Completed")
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Garage Log")
                        .font(.headline)

                    InfoLine(title: "Vehicle", value: booking.vehicleName)
                    InfoLine(title: "Service", value: booking.serviceType)
                    InfoLine(title: "Status", value: booking.status)

                    if let completionNote {
                        Divider()

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Staff Note")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text(completionNote)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                NavigationLink {

                    ChatView(
                        booking: booking,
                        senderName: "Customer"
                    )

                } label: {

                    Text("Message Garage")
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

    private var completionNote: String? {
        guard booking.status.lowercased() == "completed",
              let note = booking.completionNote?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !note.isEmpty else {
            return nil
        }

        return note
    }

    func statusReached(_ step: String) -> Bool {
        let order = [
            "Pending",
            "Inspection Started",
            "Repair In Progress",
            "Completed"
        ]

        guard let currentIndex = order.firstIndex(of: booking.status),
              let stepIndex = order.firstIndex(of: step) else {
            return false
        }

        return currentIndex >= stepIndex
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
    ServiceTrackingView(
        booking: Booking(
            userId: "1",
            vehicleId: "1",
            vehicleName: "Toyota Yaris",
            serviceType: "Oil Change",
            bookingDate: "2025-05-06",
            timeSlot: "02:00 PM",
            status: "Repair In Progress",
            createdAt: Date()
        )
    )
}
