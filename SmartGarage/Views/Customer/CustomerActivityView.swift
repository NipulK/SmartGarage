import SwiftUI

struct CustomerActivityView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    
                    HStack {
                        Image(systemName: "line.3.horizontal")
                        Text("SmartGarage")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }

                    Text("Activity")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("A complete maintenance history of your vehicle's health and service progress.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    NavigationLink(destination: ServiceTrackingView()) {
                        ActivityCard(
                            icon: "wrench.and.screwdriver.fill",
                            title: "Oil Change & Brake Check",
                            subtitle: "Currently repairing • Porsche 911",
                            tag: "IN PROGRESS",
                            color: .orange
                        )
                    }

                    ActivityCard(
                        icon: "checkmark.seal.fill",
                        title: "Full Synthetic Oil Change",
                        subtitle: "Completed • Oct 12, 2023",
                        tag: "COMPLETED",
                        color: .green
                    )

                    ActivityCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Health Alert",
                        subtitle: "Brake pad wear detected",
                        tag: "ALERT",
                        color: .red
                    )

                    ActivityCard(
                        icon: "calendar.badge.clock",
                        title: "Booking Confirmed",
                        subtitle: "Tesla Model 3 • Oct 14, 2024",
                        tag: "BOOKED",
                        color: .blue
                    )

                    Text("End of history")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ActivityCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let tag: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.12))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)

                    Spacer()

                    Text(tag)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(color.opacity(0.12))
                        .cornerRadius(8)
                }

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    CustomerActivityView()
}
