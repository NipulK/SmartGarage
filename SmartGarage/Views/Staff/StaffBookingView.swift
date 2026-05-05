import SwiftUI

struct StaffBookingView: View {
    @State private var selectedTab = "Today"

    let tabs = ["Today", "Upcoming", "In Progress"]

    var body: some View {
        NavigationStack {
            VStack {

                // Header
                HStack {
                    Text("Bookings")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()

                // Tabs
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

                ScrollView {
                    VStack(spacing: 16) {

                        NavigationLink(destination: StaffServiceDetailView()) {
                            StaffTaskCard(
                                customer: "Alex Rivera",
                                vehicle: "Porsche 911",
                                service: "Full Service",
                                time: "10:30 AM",
                                status: "CHECK-IN",
                                color: .blue
                            )
                        }

                        StaffTaskCard(
                            customer: "Sophia Chen",
                            vehicle: "Tesla Model 3",
                            service: "Battery Check",
                            time: "12:00 PM",
                            status: "PENDING",
                            color: .orange
                        )

                        StaffTaskCard(
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
            }
            .background(Color(.systemGroupedBackground))
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
