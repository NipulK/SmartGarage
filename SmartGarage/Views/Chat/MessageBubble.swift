import SwiftUI
import FirebaseAuth

struct MessageBubble: View {

    let message: Message
    var canHide = false
    var onHide: (() -> Void)?

    var isCurrentUser: Bool {
        message.senderId == Auth.auth().currentUser?.uid
    }

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 60)
            }

            VStack(
                alignment: isCurrentUser ? .trailing : .leading,
                spacing: 5
            ) {
                Text(message.senderName)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 6)

                Text(message.messageText)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        isCurrentUser
                        ? Color.blue
                        : Color(.systemGray5)
                    )
                    .foregroundColor(
                        isCurrentUser
                        ? .white
                        : .black
                    )
                    .cornerRadius(18)
            }
            .frame(
                maxWidth: UIScreen.main.bounds.width * 0.72,
                alignment: isCurrentUser ? .trailing : .leading
            )

            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity)
        .contextMenu {
            if canHide {
                Button {
                    onHide?()
                } label: {
                    Label("Hide Message", systemImage: "eye.slash")
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        MessageBubble(
            message: Message(
                senderId: Auth.auth().currentUser?.uid ?? "current",
                senderName: "Customer",
                messageText: "Hello garage team!",
                bookingId: "1",
                createdAt: Date()
            )
        )

        MessageBubble(
            message: Message(
                senderId: "staff-id",
                senderName: "Staff",
                messageText: "Hi, your vehicle service is almost completed.",
                bookingId: "1",
                createdAt: Date()
            )
        )
    }
    .padding()
}
