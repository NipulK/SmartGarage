import SwiftUI

struct NotificationListView: View {

    @StateObject private var notificationService =
    AppNotificationService()

    var body: some View {

        ScrollView {

            VStack(spacing: 14) {

                ForEach(notificationService.notifications) {
                    notification in

                    VStack(alignment: .leading, spacing: 8) {

                        Text(notification.title)
                            .fontWeight(.bold)

                        Text(notification.body)
                            .font(.caption)

                        Text(notification.senderName)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        notification.isRead
                        ? Color.white
                        : Color.blue.opacity(0.1)
                    )
                    .cornerRadius(16)
                    .onTapGesture {

                        if let id = notification.id {

                            notificationService.markAsRead(
                                notificationId: id
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .onAppear {

            notificationService.fetchNotifications(userRole: "customer")
        }
    }
}
