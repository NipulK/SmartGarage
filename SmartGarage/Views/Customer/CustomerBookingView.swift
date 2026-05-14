import SwiftUI

struct CustomerBookingView: View {

    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    var showsTopBarBackButton = true
    var onLogoutRequested: () -> Void = { }
    var onBookingConfirmed: () -> Void = { }

    @StateObject private var bookingService = BookingService()
    @StateObject private var vehicleService = VehicleService()

    private var calendarService = CalendarService()

    @State private var selectedVehicle = ""
    @State private var selectedService: String
    @State private var selectedTime = "02:00 PM"
    private let preselectedVehicleId: String?

    @State private var calendarMessage = ""
    @State private var selectedDate = Date()

    @State private var showBookingAlert = false
    @State private var bookingSummary = ""

    let defaultServices = [
        "Full System Diagnostic",
        "Oil Change & Brake Check",
        "Tire Rotation",
        "Battery Check"
    ]

    let times = [
        "09:00 AM",
        "11:30 AM",
        "02:00 PM",
        "04:30 PM"
    ]

    var services: [String] {
        if defaultServices.contains(selectedService) {
            return defaultServices
        } else {
            return [selectedService] + defaultServices
        }
    }

    init(
        selectedTab: Binding<Int> = .constant(1),
        preselectedService: String = "Full System Diagnostic",
        preselectedVehicleId: String? = nil,
        showsTopBarBackButton: Bool = true,
        onLogoutRequested: @escaping () -> Void = { },
        onBookingConfirmed: @escaping () -> Void = { }
    ) {
        self._selectedTab = selectedTab
        self._selectedService = State(initialValue: preselectedService)
        self.preselectedVehicleId = preselectedVehicleId
        self.showsTopBarBackButton = showsTopBarBackButton
        self.onLogoutRequested = onLogoutRequested
        self.onBookingConfirmed = onBookingConfirmed
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                CustomerTopBar(
                    onBack: onLogoutRequested,
                    showsBackButton: showsTopBarBackButton
                ) {
                    NavigationLink {
                        CustomerProfileView {
                            onLogoutRequested()
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Book Service")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Schedule your precision maintenance with our expert technicians.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("VEHICLE TYPE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    if vehicleService.isLoading {
                        ProgressView("Loading vehicles...")
                            .padding()
                    } else if vehicleService.vehicles.isEmpty {
                        Text("No vehicles found. Please add a vehicle first.")
                            .foregroundColor(.gray)
                    } else {
                        Picker("Vehicle", selection: $selectedVehicle) {
                            ForEach(vehicleService.vehicles) { vehicle in
                                Text("\(vehicle.make) \(vehicle.model)")
                                    .tag(vehicle.id ?? "")
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("SERVICE TYPE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    Picker("Service", selection: $selectedService) {
                        ForEach(services, id: \.self) { service in
                            Text(service)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("SCHEDULE APPOINTMENT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    VStack(spacing: 15) {
                        DatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(times, id: \.self) { time in
                                Button {
                                    selectedTime = time
                                } label: {
                                    Text(time)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(selectedTime == time ? Color.blue : Color(.systemGray6))
                                        .foregroundColor(selectedTime == time ? .white : .black)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(18)
                }

                if !bookingService.errorMessage.isEmpty {
                    Text(bookingService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if !calendarMessage.isEmpty {
                    Text(calendarMessage)
                        .foregroundColor(calendarMessage.contains("successfully") ? .green : .red)
                        .font(.caption)
                }

                Button {
                    confirmBooking()
                } label: {
                    HStack {
                        Text("Confirm Booking")
                        Image(systemName: "arrow.right")
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedVehicle.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
                .disabled(selectedVehicle.isEmpty)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Booking")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vehicleService.fetchVehicles()
        }
        .onChange(of: vehicleService.vehicles.count) {
            guard selectedVehicle.isEmpty else {
                return
            }

            if let preselectedVehicleId,
               vehicleService.vehicles.contains(where: { $0.id == preselectedVehicleId }) {
                selectedVehicle = preselectedVehicleId
            } else if let firstVehicle = vehicleService.vehicles.first {
                selectedVehicle = firstVehicle.id ?? ""
            }
        }
        .alert("Booking Confirmed", isPresented: $showBookingAlert) {
            Button("OK") {
                selectedTab = 0
                onBookingConfirmed()
                dismiss()
            }
        } message: {
            Text(bookingSummary)
        }
    }

    func confirmBooking() {
        guard let vehicle = vehicleService.vehicles.first(where: {
            $0.id == selectedVehicle
        }) else {
            bookingService.errorMessage = "Please select a vehicle."
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let bookingDate = formatter.string(from: selectedDate)

        bookingService.createBooking(
            vehicleId: vehicle.id ?? "",
            vehicleName: "\(vehicle.make) \(vehicle.model)",
            serviceType: selectedService,
            bookingDate: bookingDate,
            timeSlot: selectedTime
        ) { success in
            if success {
                bookingSummary =
                """
                Vehicle: \(vehicle.make) \(vehicle.model)

                Service:
                \(selectedService)

                Date:
                \(bookingDate)

                Time:
                \(selectedTime)

                Your booking was successfully created.
                """

                showBookingAlert = true

                addBookingToCalendar(
                    vehicleName: "\(vehicle.make) \(vehicle.model)",
                    serviceType: selectedService,
                    bookingDate: bookingDate,
                    timeSlot: selectedTime
                )
            }
        }
    }

    func addBookingToCalendar(
        vehicleName: String,
        serviceType: String,
        bookingDate: String,
        timeSlot: String
    ) {
        guard let startDate = createDate(dateString: bookingDate, timeString: timeSlot) else {
            calendarMessage = "Could not create calendar date."
            return
        }

        let endDate = Calendar.current.date(byAdding: .hour, value: 2, to: startDate) ?? startDate.addingTimeInterval(7200)

        calendarService.requestAccessAndAddEvent(
            title: "SmartGarage - \(serviceType)",
            notes: "Vehicle: \(vehicleName)",
            startDate: startDate,
            endDate: endDate
        ) { success, message in
            calendarMessage = message
        }
    }

    func createDate(dateString: String, timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(from: "\(dateString) \(timeString)")
    }
}

#Preview {
    CustomerBookingView(selectedTab: .constant(1))
}
