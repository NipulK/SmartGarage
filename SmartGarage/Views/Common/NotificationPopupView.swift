import SwiftUI

struct NotificationPopupView: View {

    let notification: AppNotification

    var body: some View {

        HStack {

            VStack(alignment: .leading, spacing: 6) {

                Text(notification.title)
                    .fontWeight(.bold)

                Text(notification.body)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "bell.badge.fill")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(radius: 8)
        .padding(.horizontal)
    }
}
