import SwiftUI
import FirebaseAuth

struct CustomerHomeView: View {

    var onLogoutRequested: () -> Void = { }
    var showsTopBarBackButton = true

    @StateObject private var vehicleService = VehicleService()
    @StateObject private var bookingService = BookingService()
    @StateObject private var notificationService = AppNotificationService()

    @State private var selectedBooking: Booking?
    @State private var showChat = false
    @State private var activePopup: AppNotification?
    @State private var customerName = "Customer"

    @State private var selectedVehicle: Vehicle?

    var latestActiveBooking: Booking? {
        bookingService.bookings.first {
            $0.status.lowercased() != "completed"
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    CustomerTopBar(
                        onBack: onLogoutRequested,
                        showsBackButton: showsTopBarBackButton
                    ) {
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
                            CustomerProfileView(
                                showsTopBarBackButton: false
                            ) {
                                onLogoutRequested()
                            }
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Hello, \(customerDisplayName)")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Track your vehicle services and garage updates in real time.")
                            .foregroundColor(.gray)
                    }

                    if let activeBooking = latestActiveBooking {
                        activeBookingCard(activeBooking)
                    } else {
                        noActiveServiceCard
                    }

                    HStack {
                        NavigationLink {
                            CustomerBookingView(
                                selectedTab: .constant(1),
                                showsTopBarBackButton: false
                            ) {
                                onLogoutRequested()
                            }
                        } label: {
                            Label("Book Service", systemImage: "calendar.badge.plus")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        NavigationLink {
                            CustomerActivityView(
                                selectedTab: .constant(3),
                                showsTopBarBackButton: false
                            ) {
                                onLogoutRequested()
                            }
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

                        NavigationLink {
                            AddVehicleView()
                        } label: {
                            Text("Add New")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
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
                                    Button {
                                        selectedVehicle = vehicle
                                    } label: {
                                        VehicleCard(
                                            name: "\(vehicle.make) \(vehicle.model)",
                                            plate: vehicle.plate
                                        )
                                    }
                                    .buttonStyle(.plain)
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
        .sheet(item: $selectedVehicle) { vehicle in
            VehicleDetailsPopup(vehicle: vehicle)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            vehicleService.fetchVehicles()
            bookingService.fetchBookings()
            loadCustomerName()

            notificationService.fetchNotifications(userRole: "customer")

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showLatestPopupIfNeeded()
            }
        }
        .onChange(of: notificationService.notifications.count) {
            showLatestPopupIfNeeded()
        }
        .onDisappear {
            activePopup = nil
        }
    }

    private func activeBookingCard(_ activeBooking: Booking) -> some View {
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
                DispatchQueue.main.async {
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
    }

    private var noActiveServiceCard: some View {
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

    private var customerDisplayName: String {
        let trimmedName = customerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? "Customer" : trimmedName
    }

    private func loadCustomerName() {
        guard let userId = Auth.auth().currentUser?.uid else {
            customerName = "Customer"
            return
        }

        bookingService.fetchCustomerName(userId: userId) { name in
            customerName = name
        }
    }

    func openChatFromPopup(_ notification: AppNotification) {
        activePopup = nil

        if let id = notification.id {
            notificationService.markAsRead(notificationId: id)
            notificationService.markPopupShown(notificationId: id)
        }

        bookingService.fetchBookingById(bookingId: notification.bookingId) { booking in
            guard let booking else { return }

            DispatchQueue.main.async {
                selectedBooking = booking
                showChat = true
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

struct VehicleDetailsPopup: View {
    let vehicle: Vehicle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Image(systemName: "car.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .frame(width: 55, height: 55)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(vehicle.make) \(vehicle.model)")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(vehicle.plate)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                }

                Divider()

                VehicleDetailLine(title: "Make", value: vehicle.make)
                VehicleDetailLine(title: "Model", value: vehicle.model)
                VehicleDetailLine(title: "Year", value: vehicle.year)
                VehicleDetailLine(title: "Color", value: vehicle.color)
                VehicleDetailLine(title: "Plate", value: vehicle.plate)
                VehicleDetailLine(title: "VIN", value: vehicle.vin)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct VehicleDetailLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)

            Spacer()

            Text(value.isEmpty ? "N/A" : value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
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
                .foregroundColor(.black)

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
                    .foregroundColor(.black)

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