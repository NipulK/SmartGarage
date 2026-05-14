import SwiftUI

struct NotificationListView: View {
    let userRole: String

    @StateObject private var notificationService = AppNotificationService()
    @StateObject private var bookingService = BookingService()

    @State private var selectedBooking: Booking?
    @State private var showChat = false
    @State private var notificationContexts: [String: NotificationChatContext] = [:]

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {

                if notificationService.notifications.isEmpty {

                    Text("No notifications yet.")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(14)

                } else {

                    ForEach(notificationService.notifications) { notification in

                        Button {
                            openChat(notification)
                        } label: {

                            NotificationChatRow(
                                notification: notification,
                                context: notificationContexts[contextKey(for: notification)]
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            loadContext(for: notification)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)

        // 🔥 IMPORTANT (navigation fix)
        .navigationDestination(isPresented: $showChat) {
            if let selectedBooking {
                ChatView(
                    booking: selectedBooking,
                    senderName: userRole == "staff" ? "Staff" : "Customer"
                )
            }
        }

        .onAppear {
            notificationService.fetchNotifications(userRole: userRole)
        }
    }

    // MARK: - HELPERS

    func contextKey(for notification: AppNotification) -> String {
        notification.id ?? notification.bookingId
    }

    func loadContext(for notification: AppNotification) {

        let key = contextKey(for: notification)

        if notificationContexts[key] != nil { return }

        bookingService.fetchBookingById(
            bookingId: notification.bookingId
        ) { booking in

            guard let booking else { return }

            bookingService.fetchCustomerName(userId: booking.userId) { customerName in

                DispatchQueue.main.async {
                    notificationContexts[key] = NotificationChatContext(
                        customerName: customerName,
                        topic: "\(booking.vehicleName) - \(booking.serviceType)",
                        schedule: "\(booking.bookingDate) at \(booking.timeSlot)",
                        status: booking.status
                    )
                }
            }
        }
    }

    // 🔥 FINAL FIXED FUNCTION
    func openChat(_ notification: AppNotification) {

        if let id = notification.id {
            notificationService.markAsRead(notificationId: id)
        }

        bookingService.fetchBookingById(
            bookingId: notification.bookingId
        ) { booking in

            guard let booking else { return }

            DispatchQueue.main.async {
                selectedBooking = booking
                showChat = true
            }
        }
    }
}

private struct NotificationChatContext {
    let customerName: String
    let topic: String
    let schedule: String
    let status: String
}

private struct NotificationChatRow: View {
    let notification: AppNotification
    let context: NotificationChatContext?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: notification.isRead ? "message" : "message.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 34, height: 34)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 5) {
                    Text(context?.customerName ?? notification.senderName)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text(context?.topic ?? "Loading booking details...")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text(notification.body)
                        .font(.caption)
                        .foregroundColor(.black)
                        .lineLimit(2)

                    if let context {
                        Text("\(context.schedule) - \(context.status)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    } else {
                        Text("Booking: \(notification.bookingId.prefix(8))")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(notification.isRead ? Color.white : Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
}
