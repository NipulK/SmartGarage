import SwiftUI

struct StaffDashboardView: View {
    
    @StateObject private var notificationService = AppNotificationService()
    @StateObject private var bookingService = BookingService()
    
    var totalBookings: Int {
        bookingService.bookings.count
    }
    
    var activeBookings: Int {
        bookingService.bookings.filter {
            $0.status.lowercased() == "pending" ||
            $0.status.lowercased() == "inspection started" ||
            $0.status.lowercased() == "repair in progress"
        }.count
    }
    
    var completedBookings: Int {
        bookingService.bookings.filter {
            $0.status.lowercased() == "completed"
        }.count
    }
    
    var latestBookings: [Booking] {
        Array(bookingService.bookings.prefix(5))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    HStack {
                        Image(systemName: "line.3.horizontal")
                        
                        Text("SmartGarage Staff")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        NavigationLink {
                            NotificationListView(userRole: "staff")
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.title3)
                                    .foregroundColor(.black)

                                if notificationService.unreadCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Good Morning, Marcus")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Here is your live garage operation overview for today.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 14
                    ) {
                        StaffStatCard(
                            title: "Bookings",
                            value: "\(totalBookings)",
                            icon: "calendar",
                            color: .blue
                        )
                        
                        StaffStatCard(
                            title: "Active",
                            value: "\(activeBookings)",
                            icon: "wrench.fill",
                            color: .orange
                        )
                        
                        StaffStatCard(
                            title: "Completed",
                            value: "\(completedBookings)",
                            icon: "checkmark.seal.fill",
                            color: .green
                        )
                        
                        StaffStatCard(
                            title: "Pending",
                            value: "\(pendingCount())",
                            icon: "clock.fill",
                            color: .purple
                        )
                    }

                    HStack {
                        Text("Latest Bookings")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            bookingService.fetchAllBookings()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }

                    if bookingService.isLoading {
                        ProgressView("Loading bookings...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if !bookingService.errorMessage.isEmpty {
                        Text(bookingService.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)
                    } else if latestBookings.isEmpty {
                        Text("No bookings available.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(latestBookings) { booking in
                                NavigationLink {
                                    StaffServiceDetailView(booking: booking)
                                } label: {
                                    StaffDashboardBookingRow(
                                        customer: "Customer ID: \(booking.userId.prefix(6))",
                                        vehicle: booking.vehicleName,
                                        service: booking.serviceType,
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
                notificationService.fetchNotifications(userRole: "staff")
                bookingService.fetchAllBookings()
            }
        }
    }
    
    func pendingCount() -> Int {
        bookingService.bookings.filter {
            $0.status.lowercased() == "pending"
        }.count
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

struct StaffStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
    }
}

struct StaffDashboardBookingRow: View {
    let customer: String
    let vehicle: String
    let service: String
    let time: String
    let status: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .foregroundColor(color)
                .frame(width: 42, height: 42)
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
                    .font(.caption)
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
                    .padding(.vertical, 4)
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
    StaffDashboardView()
}
