import SwiftUI

struct CustomerBookingView: View {
    
    @StateObject private var bookingService = BookingService()
    @StateObject private var vehicleService = VehicleService()
    @StateObject private var calendarService = CalendarService()
    
    @State private var selectedVehicle = ""
    @State private var selectedService = "Full System Diagnostic"
    @State private var selectedTime = "02:00 PM"
    @State private var showSuccessMessage = false
    @State private var calendarMessage = ""

    let services = [
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                HStack {
                    Image(systemName: "line.3.horizontal")
                    Text("SmartGarage")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Book Service")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Schedule your precision maintenance with our expert technicians in just a few taps.")
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)
                    } else if vehicleService.vehicles.isEmpty {
                        Text("No vehicles found. Please add a vehicle first.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)
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
                        Text("May 2026")
                            .font(.headline)

                        HStack {
                            ForEach(["6", "7", "8", "9", "10", "11", "12"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .frame(width: 32, height: 32)
                                    .background(day == "8" ? Color.blue : Color.clear)
                                    .foregroundColor(day == "8" ? .white : .black)
                                    .clipShape(Circle())
                            }
                        }

                        LazyVGrid(
                            columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ],
                            spacing: 12
                        ) {
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

                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)

                    VStack(alignment: .leading) {
                        Text("Estimated Time")
                            .font(.caption)
                            .foregroundColor(.gray)

                        Text("2 hours")
                            .fontWeight(.bold)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.orange.opacity(0.12))
                .cornerRadius(14)
                
                if !bookingService.errorMessage.isEmpty {
                    Text(bookingService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if showSuccessMessage {
                    Text("Booking saved successfully!")
                        .foregroundColor(.green)
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
        .onAppear {
            vehicleService.fetchVehicles()
        }
        .onChange(of: vehicleService.vehicles.count) {
            if selectedVehicle.isEmpty,
               let firstVehicle = vehicleService.vehicles.first {
                selectedVehicle = firstVehicle.id ?? ""
            }
        }
    }

    func confirmBooking() {
        guard let vehicle = vehicleService.vehicles.first(where: {
            $0.id == selectedVehicle
        }) else {
            bookingService.errorMessage = "Please select a vehicle."
            return
        }

        let bookingDate = "2026-05-08"

        bookingService.createBooking(
            vehicleId: vehicle.id ?? "",
            vehicleName: "\(vehicle.make) \(vehicle.model)",
            serviceType: selectedService,
            bookingDate: bookingDate,
            timeSlot: selectedTime
        ) { success in
            if success {
                showSuccessMessage = true
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
        guard let startDate = createDate(
            dateString: bookingDate,
            timeString: timeSlot
        ) else {
            calendarMessage = "Could not create calendar date."
            return
        }

        let endDate = Calendar.current.date(
            byAdding: .hour,
            value: 2,
            to: startDate
        ) ?? startDate.addingTimeInterval(7200)

        calendarService.requestAccessAndAddEvent(
            title: "SmartGarage - \(serviceType)",
            notes: "Vehicle: \(vehicleName)\nService: \(serviceType)",
            startDate: startDate,
            endDate: endDate
        ) { success, message in
            calendarMessage = message
        }
    }

    func createDate(
        dateString: String,
        timeString: String
    ) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(
            from: "\(dateString) \(timeString)"
        )
    }
}

#Preview {
    CustomerBookingView()
}
