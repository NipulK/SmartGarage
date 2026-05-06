import SwiftUI

struct StaffServiceDetailView: View {

    let booking: Booking

    @State private var progress: Double = 0.3
    @State private var currentStatus = "Pending"

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                Text("Service Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                // CUSTOMER & VEHICLE DETAILS
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
                .shadow(color: .gray.opacity(0.1), radius: 5)

                // PROGRESS SECTION
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

                // ACTION BUTTONS
                VStack(spacing: 14) {

                    Button {

                        progress = 0.3
                        currentStatus = "Inspection Started"

                    } label: {

                        Label("Start Inspection", systemImage: "checklist")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {

                        progress = 0.7
                        currentStatus = "Repair In Progress"

                    } label: {

                        Label("Start Repair", systemImage: "wrench.and.screwdriver")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {

                        progress = 1.0
                        currentStatus = "Completed"

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
