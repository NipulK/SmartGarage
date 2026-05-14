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
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.14),
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerView
                        .padding(.top, 24)

                    formCard

                    createAccountButton

                    Text("Your username will be used for future sign ins.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Account Created", isPresented: $showSuccessAlert) {
            Button("Go to Login") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. Please login using your username and 6-digit password.")
        }
    }

    private var headerView: some View {
        VStack(spacing: 14) {
            AppLogoMark(size: 112, cornerRadius: 26, padding: 7)
                .shadow(color: .blue.opacity(0.16), radius: 16, y: 8)

            VStack(spacing: 8) {
                Text("Create Account")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)

                Text("Set up your SmartGarage profile to book services and track repair progress.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var formCard: some View {
        VStack(spacing: 16) {
            RegisterInputField(
                title: "Username",
                placeholder: "Choose a username",
                systemImage: "person.fill",
                text: $username,
                keyboardType: .default,
                textInputAutocapitalization: .never
            )

            RegisterInputField(
                title: "Full Name",
                placeholder: "Enter your full name",
                systemImage: "person.text.rectangle.fill",
                text: $fullName,
                keyboardType: .default,
                textInputAutocapitalization: .words
            )

            RegisterInputField(
                title: "Phone Number",
                placeholder: "Enter your phone number",
                systemImage: "phone.fill",
                text: $phone,
                keyboardType: .phonePad,
                textInputAutocapitalization: .never
            )

            RegisterPasswordField(password: $password)

            passwordRequirement

            errorView
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
    }

    private var passwordRequirement: some View {
        HStack(spacing: 8) {
            Image(systemName: isPasswordValid ? "checkmark.circle.fill" : "info.circle.fill")
                .foregroundColor(isPasswordValid ? .green : .gray)

            Text(isPasswordValid ? "6-digit password ready" : "Password must be exactly 6 numbers")
                .font(.footnote)
                .foregroundColor(isPasswordValid ? .green : .gray)

            Spacer()
        }
        .padding(.horizontal, 4)
    }

    @ViewBuilder
    private var errorView: some View {
        let message = !localErrorMessage.isEmpty ? localErrorMessage : authVM.errorMessage

        if !message.isEmpty {
            Label(message, systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.red.opacity(0.08))
                .cornerRadius(14)
        }
    }

    private var createAccountButton: some View {
        Button {
            register()
        } label: {
            HStack(spacing: 10) {
                if authVM.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "person.badge.plus")
                    Text("Create Account")
                        .fontWeight(.bold)
                }
            }
            .font(.system(size: 18, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
        }
        .background(isFormValid ? Color.blue : Color.gray.opacity(0.42))
        .foregroundColor(.white)
        .cornerRadius(16)
        .shadow(color: isFormValid ? .blue.opacity(0.22) : .clear, radius: 12, y: 8)
        .disabled(!isFormValid || authVM.isLoading)
    }

    var isFormValid: Bool {
        !username.trimmingCharacters(in: .whitespaces).isEmpty &&
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phone.trimmingCharacters(in: .whitespaces).isEmpty &&
        isPasswordValid
    }

    private var isPasswordValid: Bool {
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

private struct RegisterInputField: View {
    let title: String
    let placeholder: String
    let systemImage: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textInputAutocapitalization: TextInputAutocapitalization

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(.blue)
                    .frame(width: 22)

                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(textInputAutocapitalization)
                    .autocorrectionDisabled()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

private struct RegisterPasswordField: View {
    @Binding var password: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("6-Digit Password")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundColor(.blue)
                    .frame(width: 22)

                SecureField("Create your password", text: $password)
                    .keyboardType(.numberPad)
                    .onChange(of: password) { newValue in
                        let digits = newValue.filter { $0.isNumber }
                        let limitedDigits = String(digits.prefix(6))

                        if limitedDigits != newValue {
                            password = limitedDigits
                        }
                    }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
