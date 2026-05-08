import SwiftUI

struct CustomerHomeView: View {

    @StateObject private var vehicleService = VehicleService()
    @StateObject private var bookingService = BookingService()
    @StateObject private var notificationService = AppNotificationService()

    @State private var selectedBooking: Booking?
    @State private var showChat = false
    @State private var activePopup: AppNotification?

    var latestActiveBooking: Booking? {
        bookingService.bookings.first {
            $0.status.lowercased() != "completed"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {

                        HStack {
                            Image(systemName: "line.3.horizontal")

                            Text("SmartGarage")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)

                            Spacer()

                            NavigationLink {
                                NotificationListView(userRole: "customer")
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

                            NavigationLink {
                                CustomerProfileView()
                            } label: {
                                Image(systemName: "person.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.black)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Hello, Customer")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Track your vehicle services and garage updates in real time.")
                                .foregroundColor(.gray)
                        }

                        if let activeBooking = latestActiveBooking {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("VEHICLE IN SERVICE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(statusColor(activeBooking.status))

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(activeBooking.vehicleName)
                                            .font(.headline)

                                        Text("Booking ID: \(activeBooking.id?.prefix(8) ?? "N/A")")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    VStack {
                                        Text("TIME")
                                            .font(.caption2)
                                            .foregroundColor(.gray)

                                        Text(activeBooking.timeSlot)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }

                                Text(activeBooking.status.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)

                                ProgressView(value: progressValue(for: activeBooking.status))

                                HStack {
                                    InfoBox(
                                        icon: "slider.horizontal.3",
                                        title: "TYPE",
                                        value: activeBooking.serviceType
                                    )

                                    InfoBox(
                                        icon: "calendar",
                                        title: "DATE",
                                        value: activeBooking.bookingDate
                                    )
                                }

                                Button {
                                    selectedBooking = activeBooking
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showChat = true
                                    }
                                } label: {
                                    Label("Message Garage", systemImage: "message.fill")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(22)
                            .shadow(color: .gray.opacity(0.15), radius: 8)
                        } else {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("NO ACTIVE SERVICE")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)

                                Text("You do not have any active vehicle service right now.")
                                    .font(.headline)

                                Text("Create a booking to start tracking your service progress.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(22)
                            .shadow(color: .gray.opacity(0.15), radius: 8)
                        }

                        HStack {
                            NavigationLink {
                                CustomerBookingView()
                            } label: {
                                Label("Book Service", systemImage: "calendar.badge.plus")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            NavigationLink {
                                CustomerActivityView()
                            } label: {
                                Label("View History", systemImage: "clock.arrow.circlepath")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                        }

                        HStack {
                            Text("My Vehicles")
                                .font(.headline)

                            Spacer()

                            Text("Add New")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if vehicleService.isLoading {
                                    ProgressView()
                                        .padding()
                                } else if vehicleService.vehicles.isEmpty {
                                    Text("No vehicles added yet")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ForEach(vehicleService.vehicles) { vehicle in
                                        VehicleCard(
                                            name: "\(vehicle.make) \(vehicle.model)",
                                            plate: vehicle.plate
                                        )
                                    }
                                }
                            }
                        }

                        if !vehicleService.errorMessage.isEmpty {
                            Text(vehicleService.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }

                        Text("Recent Updates")
                            .font(.headline)

                        if bookingService.bookings.isEmpty {
                            Text("No recent service updates yet.")
                                .foregroundColor(.gray)
                                .font(.caption)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(14)
                        } else {
                            ForEach(bookingService.bookings.prefix(3)) { booking in
                                NavigationLink {
                                    ServiceTrackingView(booking: booking)
                                } label: {
                                    UpdateRow(
                                        title: "\(booking.serviceType) - \(booking.status)",
                                        time: "\(booking.vehicleName) • \(booking.timeSlot)"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))

                if let activePopup {
                    NotificationPopupView(notification: activePopup)
                        .padding(.top, 10)
                        .transition(.move(edge: .top))
                        .onTapGesture {
                            openChatFromPopup(activePopup)
                        }
                }
            }
            .navigationDestination(isPresented: $showChat) {
                if let booking = selectedBooking {
                    ChatView(
                        booking: booking,
                        senderName: "Customer"
                    )
                }
            }
            .onAppear {
                vehicleService.fetchVehicles()
                bookingService.fetchBookings()
                notificationService.fetchNotifications(userRole: "customer")

                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showLatestPopupIfNeeded()
                }
            }
            .onChange(of: notificationService.notifications.count) {
                showLatestPopupIfNeeded()
            }
        }
    }

    func showLatestPopupIfNeeded() {
        guard activePopup == nil else { return }

        if let notification = notificationService.latestUnreadNotification {
            activePopup = notification

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if activePopup?.id == notification.id {
                    activePopup = nil

                    if let id = notification.id {
                        notificationService.markPopupShown(notificationId: id)
                    }
                }
            }
        }
    }
    

    func openChatFromPopup(_ notification: AppNotification) {
        activePopup = nil

        if let id = notification.id {
            notificationService.markAsRead(notificationId: id)
            notificationService.markPopupShown(notificationId: id)
        }

        BookingService().fetchBookingById(bookingId: notification.bookingId) { booking in
            if let booking {
                selectedBooking = booking

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showChat = true
                }
            }
        }
    }

    func progressValue(for status: String) -> Double {
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

struct InfoBox: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}

struct VehicleCard: View {
    let name: String
    let plate: String

    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 180, height: 100)
                .overlay(
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )

            Text(name)
                .fontWeight(.bold)

            Text(plate)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct UpdateRow: View {
    let title: String
    let time: String

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 4, height: 45)

            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)

                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}

#Preview {
    CustomerHomeView()
}
