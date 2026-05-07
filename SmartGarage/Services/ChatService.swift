import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

class ChatService: ObservableObject {

    @Published var messages: [Message] = []
    @Published var errorMessage = ""

    private let db = Firestore.firestore()

    private var listener: ListenerRegistration?

    deinit {
        listener?.remove()
    }

    func sendMessage(
        bookingId: String,
        senderName: String,
        messageText: String,
        completion: @escaping (Bool) -> Void
    ) {

        guard let senderId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            completion(false)
            return
        }

        let message = Message(
            senderId: senderId,
            senderName: senderName,
            messageText: messageText,
            bookingId: bookingId,
            createdAt: Date()
        )

        do {

            _ = try db.collection("chatRooms")
                .document(bookingId)
                .collection("messages")
                .addDocument(from: message) { error in

                    DispatchQueue.main.async {

                        if let error = error {
                            self.errorMessage = error.localizedDescription
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
                }

        } catch {

            errorMessage = error.localizedDescription
            completion(false)
        }
    }

    func fetchMessages(bookingId: String) {

        listener?.remove()

        listener = db.collection("chatRooms")
            .document(bookingId)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { snapshot, error in

                DispatchQueue.main.async {

                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    

                    self.messages = snapshot?.documents.compactMap {
                        try? $0.data(as: Message.self)
                    } ?? []
                }
            }
    }
}
