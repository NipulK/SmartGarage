import SwiftUI

struct ChatView: View {

    let booking: Booking
    let senderName: String


    @StateObject private var chatService = ChatService()
    @StateObject private var bookingService = BookingService()
    @State private var messageText = ""
    @State private var customerName = "Customer"
    @State private var resolvedSenderName: String

    private var isStaffMember: Bool {
        senderName == "Staff"
    }

    init(booking: Booking, senderName: String) {
        self.booking = booking
        self.senderName = senderName
        _resolvedSenderName = State(initialValue: senderName)
    }

    var body: some View {
        VStack(spacing: 0) {

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if isStaffMember {
                            NavigationLink {
                                StaffServiceDetailView(booking: booking)
                            } label: {
                                ConversationHeader(
                                    customerName: customerName,
                                    vehicleName: booking.vehicleName,
                                    serviceType: booking.serviceType,
                                    bookingDate: booking.bookingDate,
                                    timeSlot: booking.timeSlot,
                                    status: booking.status,
                                    showsNavigationIndicator: true
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.bottom, 4)
                        } else {
                            ConversationHeader(
                                customerName: customerName,
                                vehicleName: booking.vehicleName,
                                serviceType: booking.serviceType,
                                bookingDate: booking.bookingDate,
                                timeSlot: booking.timeSlot,
                                status: booking.status
                            )
                            .padding(.bottom, 4)
                        }

                        ForEach(chatService.messages) { message in
                            MessageBubble(
                                message: message,
                                canHide: isStaffMember
                            ) {
                                hideMessage(message)
                            }
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
            chatService.fetchMessages(
                bookingId: bookingId,
                hideMessagesHiddenByCurrentStaff: isStaffMember
            )
            loadCustomerName()
        }
    }

    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        chatService.sendMessage(
            booking: booking,
            senderName: resolvedSenderName,
            messageText: messageText
        ) { success in
            if success {
                messageText = ""
            }
        }
    }

    private func loadCustomerName() {
        bookingService.fetchCustomerName(userId: booking.userId) { name in
            customerName = name

            if senderName == "Customer" {
                resolvedSenderName = name
            }
        }
    }

    private func hideMessage(_ message: Message) {
        guard isStaffMember,
              let bookingId = booking.id,
              let messageId = message.id else {
            return
        }

        chatService.hideMessageForCurrentStaff(
            bookingId: bookingId,
            messageId: messageId
        ) { _ in }
    }
}

private struct ConversationHeader: View {
    let customerName: String
    let vehicleName: String
    let serviceType: String
    let bookingDate: String
    let timeSlot: String
    let status: String
    var showsNavigationIndicator = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(customerName)
                        .font(.headline)
                        .foregroundColor(.black)

                    Text("\(vehicleName) - \(serviceType)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Text("\(bookingDate) at \(timeSlot)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                if showsNavigationIndicator {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }

            Text("Status: \(status)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
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
