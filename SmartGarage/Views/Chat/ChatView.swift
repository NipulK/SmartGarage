import SwiftUI

struct ChatView: View {

    let booking: Booking
    let senderName: String

    @StateObject private var chatService = ChatService()
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatService.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 10)
                }
                .onChange(of: chatService.messages.count) {
                    if let lastMessage = chatService.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastMessage, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 12) {
                TextField("Type message...", text: $messageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color.white)
        }
        .navigationTitle("Garage Chat")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.white)
        .onAppear {
            guard let bookingId = booking.id else { return }
            chatService.fetchMessages(bookingId: bookingId)
        }
    }

    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
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
    NavigationStack {
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
}
