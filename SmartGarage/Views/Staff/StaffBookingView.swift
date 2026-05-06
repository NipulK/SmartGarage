import SwiftUI

struct StaffBookingView: View {
    @StateObject private var bookingService = BookingService()
    @State private var selectedTab = "Today"

    let tabs = ["Today", "Upcoming", "In Progress"]

    var filteredBookings: [Booking] {
        if selectedTab == "In Progress" {
            return bookingService.bookings.filter { $0.status == "In Progress" }
        } else if selectedTab == "Upcoming" {
            return bookingService.bookings.filter { $0.status == "Pending" }
        } else {
            return bookingService.bookings
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Bookings")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()

                HStack {
                    ForEach(tabs, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(selectedTab == tab ? .white : .blue)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(selectedTab == tab ? Color.blue : Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)

                if bookingService.isLoading {
                    Spacer()
                    ProgressView("Loading bookings...")
                    Spacer()
                } else if filteredBookings.isEmpty {
                    Spacer()
                    Text("No bookings found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredBookings) { booking in
                                NavigationLink(destination: StaffServiceDetailView(booking: booking)) {
                                    StaffTaskCard(
                                        customer: "Customer",
                                        vehicle: booking.vehicleName,
                                        service: booking.serviceType,
                                        time: booking.timeSlot,
                                        status: booking.status.uppercased(),
                                        color: booking.status == "Pending" ? .orange : .green
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                bookingService.fetchAllBookings()
            }
        }
    }
}

struct StaffTaskCard: View {
    let customer: String
    let vehicle: String
    let service: String
    let time: String
    let status: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: "car.fill")
                .foregroundColor(color)
                .frame(width: 45, height: 45)
                .background(color.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 5) {
                Text(customer)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(vehicle)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(service)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(time)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text(status)
                    .font(.caption2)
                    .foregroundColor(color)
                    .padding(6)
                    .background(color.opacity(0.12))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    StaffBookingView()
}
