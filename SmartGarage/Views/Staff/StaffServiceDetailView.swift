import SwiftUI


struct StaffServiceDetailView: View {

    let booking: Booking

    @StateObject private var bookingService = BookingService()

    @State private var progress: Double
    @State private var currentStatus: String
    @State private var showSuccessMessage = false

    init(booking: Booking) {
        self.booking = booking
        _currentStatus = State(initialValue: booking.status)
        _progress = State(initialValue: StaffServiceDetailView.progressValue(for: booking.status))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("Service Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 12) {
                    Label("Vehicle Information", systemImage: "car.fill")
                        .font(.headline)

                    Divider()

                    Text("Vehicle: \(booking.vehicleName)")
                        .fontWeight(.semibold)

                    Text("Service: \(booking.serviceType)")
                    Text("Date: \(booking.bookingDate)")
                    Text("Time: \(booking.timeSlot)")

                    Text("Status: \(currentStatus)")
                        .foregroundColor(statusColor(currentStatus))
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Service Progress")
                        .font(.headline)

                    ProgressView(value: progress)

                    Text("\(Int(progress * 100))% Completed")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)

                if !bookingService.errorMessage.isEmpty {
                    Text(bookingService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if showSuccessMessage {
                    Text("Status updated successfully!")
                        .foregroundColor(.green)
                        .font(.caption)
                }

                VStack(spacing: 14) {
                    Button {
                        updateStatus("Inspection Started")
                    } label: {
                        Label("Start Inspection", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        updateStatus("Repair In Progress")
                    } label: {
                        Label("Start Repair", systemImage: "wrench.and.screwdriver")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        updateStatus("Completed")
                    } label: {
                        Label("Complete Service", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    
                    NavigationLink {

                        ChatView(
                            booking: booking,
                            senderName: "Staff"
                        )

                    } label: {

                        Label("Open Chat", systemImage: "message.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    func updateStatus(_ status: String) {
        guard let bookingId = booking.id else {
            bookingService.errorMessage = "Booking ID not found."
            return
        }

        bookingService.updateBookingStatus(
            bookingId: bookingId,
            status: status
        ) { success in
            if success {
                currentStatus = status
                progress = StaffServiceDetailView.progressValue(for: status)
                showSuccessMessage = true
            }
        }
    }

    static func progressValue(for status: String) -> Double {
        switch status.lowercased() {
        case "pending":
            return 0.1
        case "inspection started":
            return 0.3
        case "repair in progress":
            return 0.7
        case "completed":
            return 1.0
        default:
            return 0.1
        }
    }

    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending":
            return .orange
        case "inspection started":
            return .blue
        case "repair in progress":
            return .purple
        case "completed":
            return .green
        default:
            return .gray
        }
    }
}

#Preview {
    StaffServiceDetailView(
        booking: Booking(
            userId: "1",
            vehicleId: "1",
            vehicleName: "Toyota Yaris",
            serviceType: "Oil Change",
            bookingDate: "2025-05-06",
            timeSlot: "02:00 PM",
            status: "Pending",
            createdAt: Date()
        )
    )
}
