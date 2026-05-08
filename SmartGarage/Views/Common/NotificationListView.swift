import SwiftUI

struct NotificationListView: View {
    let userRole: String

    @StateObject private var notificationService = AppNotificationService()
    @StateObject private var bookingService = BookingService()

    @State private var selectedBooking: Booking?
    @State private var showChat = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(notificationService.notifications) { notification in
                    Button {
                        openChat(notification)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(notification.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text(notification.body)
                                .font(.caption)
                                .foregroundColor(.black)

                            Text("From: \(notification.senderName)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(notification.isRead ? Color.white : Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Notifications")
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

    func openChat(_ notification: AppNotification) {
        if let id = notification.id {
            notificationService.markAsRead(notificationId: id)
        }

        bookingService.fetchBookingById(bookingId: notification.bookingId) { booking in
            if let booking {
                selectedBooking = booking

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showChat = true
                }
            }
        }
    }
}
