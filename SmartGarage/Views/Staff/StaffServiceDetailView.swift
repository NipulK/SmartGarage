import SwiftUI

struct StaffServiceDetailView: View {

    let booking: Booking

    @StateObject private var bookingService = BookingService()

    @State private var progress: Double = 0.3
    @State private var currentStatus: String
    @State private var showSuccessMessage = false

    init(booking: Booking) {
        self.booking = booking
        _currentStatus = State(initialValue: booking.status)

        if booking.status.lowercased() == "inspection started" {
            _progress = State(initialValue: 0.3)
        } else if booking.status.lowercased() == "repair in progress" {
            _progress = State(initialValue: 0.7)
        } else if booking.status.lowercased() == "completed" {
            _progress = State(initialValue: 1.0)
        } else {
            _progress = State(initialValue: 0.1)
        }
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
                        .foregroundColor(.blue)
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
                        updateStatus("Inspection Started", progressValue: 0.3)
                    } label: {
                        Label("Start Inspection", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        updateStatus("Repair In Progress", progressValue: 0.7)
                    } label: {
                        Label("Start Repair", systemImage: "wrench.and.screwdriver")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        updateStatus("Completed", progressValue: 1.0)
                    } label: {
                        Label("Complete Service", systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    func updateStatus(_ status: String, progressValue: Double) {
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
                progress = progressValue
                showSuccessMessage = true
            }
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
