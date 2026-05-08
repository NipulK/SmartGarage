import SwiftUI

struct StaffActivityView: View {

    @StateObject private var bookingService = BookingService()

    var recentActivities: [Booking] {
        Array(bookingService.bookings.prefix(8))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    HStack {
                        Image(systemName: "line.3.horizontal")

                        Text("Staff Activity")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)

                        Spacer()

                        Image(systemName: "clock.fill")
                            .font(.title3)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Garage Activity")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Track recent booking updates and service progress.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    if bookingService.isLoading {
                        ProgressView("Loading activities...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if recentActivities.isEmpty {
                        Text("No recent activities found.")
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(16)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(recentActivities) { booking in
                                NavigationLink {
                                    StaffServiceDetailView(booking: booking)
                                } label: {
                                    StaffActivityRow(
                                        vehicle: booking.vehicleName,
                                        service: booking.serviceType,
                                        date: booking.bookingDate,
                                        time: booking.timeSlot,
                                        status: booking.status,
                                        color: statusColor(booking.status)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                bookingService.fetchAllBookings()
            }
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

struct StaffActivityRow: View {
    let vehicle: String
    let service: String
    let date: String
    let time: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconForStatus(status))
                .foregroundColor(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 5) {
                Text(service)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(vehicle)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(date) • \(time)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(status.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(color.opacity(0.12))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    func iconForStatus(_ status: String) -> String {
        switch status.lowercased() {
        case "pending":
            return "clock.fill"
        case "inspection started":
            return "magnifyingglass.circle.fill"
        case "repair in progress":
            return "wrench.and.screwdriver.fill"
        case "completed":
            return "checkmark.seal.fill"
        default:
            return "car.fill"
        }
    }
}

#Preview {
    StaffActivityView()
}
