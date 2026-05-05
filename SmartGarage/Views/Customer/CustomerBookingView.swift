import SwiftUI

struct CustomerBookingView: View {
    @State private var selectedService = "Full System Diagnostic"
    @State private var selectedTime = "02:00 PM"

    let services = ["Full System Diagnostic", "Oil Change & Brake Check", "Tire Rotation", "Battery Check"]
    let times = ["09:00 AM", "11:30 AM", "02:00 PM", "04:30 PM"]

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

                    SelectionCard(icon: "car.fill", title: "Tesla Model 3", subtitle: "Midnight Silver")
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
                        Text("September 2024")
                            .font(.headline)

                        HStack {
                            ForEach(["26", "27", "28", "29", "30", "1", "2"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .frame(width: 32, height: 32)
                                    .background(day == "30" ? Color.blue : Color.clear)
                                    .foregroundColor(day == "30" ? .white : .black)
                                    .clipShape(Circle())
                            }
                        }

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

                Button {
                    print("Booking confirmed")
                } label: {
                    HStack {
                        Text("Confirm Booking")
                        Image(systemName: "arrow.right")
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct SelectionCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.down")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}

#Preview {
    CustomerBookingView()
}
