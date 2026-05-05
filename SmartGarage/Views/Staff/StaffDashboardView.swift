import SwiftUI

struct StaffDashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                HStack {
                    Image(systemName: "line.3.horizontal")
                    Text("SmartGarage Staff")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "bell")
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Good Morning, Marcus")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Here is your garage operation overview for today.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    StaffStatCard(title: "Bookings", value: "24", icon: "calendar", color: .blue)
                    StaffStatCard(title: "Active", value: "08", icon: "wrench.fill", color: .orange)
                    StaffStatCard(title: "Completed", value: "16", icon: "checkmark.seal.fill", color: .green)
                    StaffStatCard(title: "Revenue", value: "$8.4K", icon: "dollarsign.circle.fill", color: .purple)
                }

                Text("Today’s Bookings")
                    .font(.headline)

                StaffBookingRow(
                    customer: "Alex Rivera",
                    vehicle: "Porsche 911 Carrera S",
                    service: "Full Service",
                    time: "10:30 AM",
                    status: "CHECK-IN",
                    color: .blue
                )

                StaffBookingRow(
                    customer: "Sophia Chen",
                    vehicle: "Tesla Model 3",
                    service: "Battery Check",
                    time: "12:00 PM",
                    status: "PENDING",
                    color: .orange
                )

                StaffBookingRow(
                    customer: "David Miller",
                    vehicle: "BMW M4",
                    service: "Brake Repair",
                    time: "02:30 PM",
                    status: "IN PROGRESS",
                    color: .green
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
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

struct StaffBookingRow: View {
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

                Text(status)
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
