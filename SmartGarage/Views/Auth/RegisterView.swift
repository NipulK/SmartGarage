import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @StateObject private var authVM = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var username = ""
    @State private var fullName = ""
    @State private var phone = ""
    @State private var password = ""

    @State private var showSuccessAlert = false
    @State private var localErrorMessage = ""

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text("Create Customer Account")
                .font(.title)
                .fontWeight(.bold)

            TextField("Username", text: $username)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            TextField("Full Name", text: $fullName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            TextField("Phone Number", text: $phone)
                .keyboardType(.phonePad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            SecureField("Create 6-digit password", text: $password)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Text("Please create a 6-digit password for your account.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)

            if !localErrorMessage.isEmpty {
                Text(localErrorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            if !authVM.errorMessage.isEmpty {
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }

            Button {
                register()
            } label: {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Create Account")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(!isFormValid || authVM.isLoading)

            Spacer()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Account Created", isPresented: $showSuccessAlert) {
            Button("Go to Login") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. Please login using your username and 6-digit password.")
        }
    }

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count == 6 &&
        password.allSatisfy { $0.isNumber }
    }

    func register() {
        localErrorMessage = ""

        guard password.count == 6,
              password.allSatisfy({ $0.isNumber }) else {
            localErrorMessage = "Password must be exactly 6 digits."
            return
        }

        let email = "\(username.lowercased())@smartgarage.com"

        authVM.register(
            email: email,
            password: password,
            username: username,
            fullName: fullName,
            phone: phone
        ) { success in
            if success {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print(error.localizedDescription)
                }

                showSuccessAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
