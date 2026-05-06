import SwiftUI

struct RegisterView: View {
    @StateObject private var authVM = AuthViewModel()

    @State private var username = ""
    @State private var fullName = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var goToCustomer = false

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

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

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
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()

            NavigationLink("", destination: CustomerMainView(), isActive: $goToCustomer)
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    func register() {
        let email = "\(username.lowercased())@smartgarage.com"

        authVM.register(
            email: email,
            password: password,
            username: username,
            fullName: fullName,
            phone: phone
        ) { success in
            if success {
                goToCustomer = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
