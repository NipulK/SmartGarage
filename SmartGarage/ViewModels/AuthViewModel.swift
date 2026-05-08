import FirebaseFirestore
import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    func register(
        email: String,
        password: String,
        username: String,
        fullName: String,
        phone: String,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                    return
                }
                
                guard let uid = result?.user.uid else {
                    self.errorMessage = "User ID not found."
                    completion(false)
                    return
                }
                
                let userData: [String: Any] = [
                    "uid": uid,
                    "username": username.lowercased(),
                    "fullName": fullName,
                    "phone": phone,
                    "email": email,
                    "role": "customer",
                    "createdAt": Timestamp()
                ]
                
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .setData(userData) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                self.errorMessage = error.localizedDescription
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
            }
        }
    }
}
