import SwiftUI
import FirebaseAuth

struct MessageBubble: View {

    let message: Message

    var isCurrentUser: Bool {
        message.senderId == Auth.auth().currentUser?.uid
    }

    var body: some View {

        HStack {

            if isCurrentUser {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {

                Text(message.senderName)
                    .font(.caption2)
                    .foregroundColor(.gray)

                Text(message.messageText)
                    .padding()
                    .background(
                        isCurrentUser
                        ? Color.blue
                        : Color.gray.opacity(0.2)
                    )
                    .foregroundColor(
                        isCurrentUser
                        ? .white
                        : .black
                    )
                    .cornerRadius(16)
            }
            .frame(maxWidth: 260, alignment: .leading)

            if !isCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {

    MessageBubble(
        message: Message(
            senderId: "1",
            senderName: "Alex",
            messageText: "Hello garage team!",
            bookingId: "1",
            createdAt: Date()
        )
    )
}
