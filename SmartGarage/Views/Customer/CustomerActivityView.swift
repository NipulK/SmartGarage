import SwiftUI

struct CustomerActivityView: View {

    @StateObject private var bookingService = BookingService()
    @StateObject private var damageService = DamageDetectionService()

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

                    Text("Track your booking status, service progress, and saved damage reports.")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Service Bookings")
                        .font(.headline)

                    if bookingService.isLoading {
                        ProgressView("Loading activities...")
                            .frame(maxWidth: .infinity)
                            .padding()

                    } else if bookingService.bookings.isEmpty {
                        Text("No service activities found.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)

                    } else {
                        ForEach(bookingService.bookings) { booking in
                            NavigationLink {
                                ServiceTrackingView(booking: booking)
                            } label: {
                                ActivityCard(
                                    icon: iconForStatus(booking.status),
                                    title: booking.serviceType,
                                    subtitle: "\(booking.vehicleName) • \(booking.bookingDate) • \(booking.timeSlot)",
                                    tag: booking.status.uppercased(),
                                    color: colorForStatus(booking.status)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Saved Damage Reports")
                        .font(.headline)
                        .padding(.top)

                    if damageService.damageReports.isEmpty {
                        Text("No saved damage reports yet.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)

                    } else {
                        ForEach(damageService.damageReports) { report in
                            DamageReportCard(report: report)
                        }
                    }

                    Text("End of history")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                bookingService.fetchBookings()
                damageService.fetchDamageReports()
            }
        }
    }

    func colorForStatus(_ status: String) -> Color {
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

    func iconForStatus(_ status: String) -> String {
        switch status.lowercased() {
        case "pending":
            return "calendar.badge.clock"
        case "inspection started":
            return "magnifyingglass.circle.fill"
        case "repair in progress":
            return "wrench.and.screwdriver.fill"
        case "completed":
            return "checkmark.seal.fill"
        default:
            return "clock.fill"
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

struct DamageReportCard: View {
    let report: DamageReport

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(report.severity.lowercased() == "high" ? .red : .orange)
                .frame(width: 42, height: 42)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 5) {
                Text(report.damageType)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(report.vehicleName)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Cost: \(report.estimatedCost)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(report.severity.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(report.severity.lowercased() == "high" ? .red : .orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    CustomerActivityView()
}
