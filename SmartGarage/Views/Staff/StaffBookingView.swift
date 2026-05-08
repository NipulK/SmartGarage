import SwiftUI

struct StaffBookingView: View {
    let initialTab: String

    @StateObject private var bookingService = BookingService()
    @State private var selectedTab: String

    let tabs = ["All", "Pending", "Active", "Completed"]

    init(initialTab: String = "All") {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }

    var filteredBookings: [Booking] {
        switch selectedTab {
        case "Pending":
            return bookingService.bookings.filter {
                $0.status.lowercased() == "pending"
            }

        case "Active":
            return bookingService.bookings.filter {
                $0.status.lowercased() == "inspection started" ||
                $0.status.lowercased() == "repair in progress"
            }

        case "Completed":
            return bookingService.bookings.filter {
                $0.status.lowercased() == "completed"
            }

        default:
            return bookingService.bookings
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(selectedTab) Bookings")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Manage customer service bookings")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button {
                        bookingService.fetchAllBookings()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
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
                } else if !bookingService.errorMessage.isEmpty {
                    Spacer()
                    Text(bookingService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if filteredBookings.isEmpty {
                    Spacer()
                    Text("No \(selectedTab.lowercased()) bookings found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(filteredBookings) { booking in
                                NavigationLink {
                                    StaffServiceDetailView(booking: booking)
                                } label: {
                                    StaffTaskCard(
                                        customer: "Customer ID: \(booking.userId.prefix(6))",
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
                        .padding()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                selectedTab = initialTab
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

struct StaffTaskCard: View {
    let customer: String
    let vehicle: String
    let service: String
    let date: String
    let time: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
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

                Text(date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(time)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text(status.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
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
    StaffBookingView(initialTab: "All")
}
