import SwiftUI

struct ChatView: View {

    let booking: Booking
    let senderName: String

    @StateObject private var chatService = ChatService()

    @State private var messageText = ""

    var body: some View {

        VStack {

            ScrollViewReader { proxy in

                ScrollView {

                    VStack(spacing: 14) {

                        ForEach(chatService.messages) { message in

                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatService.messages.count) {

                    if let lastMessage = chatService.messages.last?.id {

                        proxy.scrollTo(lastMessage, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {

                TextField(
                    "Type message...",
                    text: $messageText
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(14)

                Button {

                    sendMessage()

                } label: {

                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .navigationTitle("Garage Chat")
        .navigationBarTitleDisplayMode(.inline)

        .onAppear {

            guard let bookingId = booking.id else { return }

            chatService.fetchMessages(
                bookingId: bookingId
            )
        }
    }

    func sendMessage() {

        guard let bookingId = booking.id else { return }

        guard !messageText.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty else {
            return
        }

        
        chatService.sendMessage(
            booking: booking,
            senderName: senderName,
            messageText: messageText
        ) { success in
            if success {
                messageText = ""
            }
        }
    }
}

#Preview {

    ChatView(
        booking: Booking(
            userId: "1",
            vehicleId: "1",
            vehicleName: "Toyota Yaris",
            serviceType: "Oil Change",
            bookingDate: "2025-05-06",
            timeSlot: "02:00 PM",
            status: "Pending",
            createdAt: Date()
        ),
        senderName: "Alex"
    )
    
}
