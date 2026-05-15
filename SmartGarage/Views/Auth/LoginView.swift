import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var authVM = AuthViewModel()

    @State private var email = ""
    @State private var password = ""
    @State private var goToCustomer = false
    @State private var goToStaff = false
    @State private var showFaceIDButton = false
    @State private var faceIDErrorMessage = ""

    private var isStaffUsername: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .hasPrefix("s_")
    }

    private var isLoginReady: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        password.count == 6 &&
        password.allSatisfy { $0.isNumber }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            AppLogoMark(size: 112, cornerRadius: 26, padding: 7)

            Text("SmartGarage")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Customer or Staff username", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: email) { _ in
                    faceIDErrorMessage = ""

                    if isStaffUsername {
                        showFaceIDButton = false
                    } else {
                        checkSavedCustomerLogin()
                    }
                }

            SecureField("Password", text: $password)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: password) { newValue in
                    let digits = newValue.filter { $0.isNumber }
                    password = String(digits.prefix(6))
                }

            if !authVM.errorMessage.isEmpty {
                errorBox(authVM.errorMessage)
            }

            if !faceIDErrorMessage.isEmpty {
                errorBox(faceIDErrorMessage)
            }

            Button {
                login()
            } label: {
                if authVM.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isLoginReady ? Color.blue : Color.gray.opacity(0.45))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(!isLoginReady || authVM.isLoading)

            if showFaceIDButton && !isStaffUsername {
                Button {
                    loginWithFaceID()
                } label: {
                    Label("Login with Face ID", systemImage: "faceid")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            Spacer()
        }
        .onAppear {
            checkSavedCustomerLogin()

            if showFaceIDButton && !isStaffUsername {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    loginWithFaceID()
                }
            }
        }
        .fullScreenCover(isPresented: $goToCustomer) {
            CustomerMainView(isCustomerLoggedIn: $goToCustomer)
        }
        .fullScreenCover(isPresented: $goToStaff) {
            StaffMainView(isStaffLoggedIn: $goToStaff)
        }
    }

    @ViewBuilder
    func errorBox(_ message: String) -> some View {
        Label(message, systemImage: "exclamationmark.circle.fill")
            .font(.caption)
            .foregroundColor(.red)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.red.opacity(0.08))
            .cornerRadius(12)
            .padding(.horizontal)
    }

    func login() {
        faceIDErrorMessage = ""

        let cleanUsername = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let isStaff = cleanUsername.hasPrefix("s_")

        let loginEmail: String

        if isStaff {
            loginEmail = "\(cleanUsername)@staff.smartgarage.com"
        } else {
            loginEmail = "\(cleanUsername)@smartgarage.com"
        }

        authVM.login(email: loginEmail, password: password) { success in
            if success {
                if isStaff {
                    showFaceIDButton = false
                    goToStaff = true
                } else {
                    KeychainHelper.shared.save(loginEmail, for: "customerEmail")
                    KeychainHelper.shared.save(password, for: "customerPassword")
                    showFaceIDButton = true
                    goToCustomer = true
                }
            }
        }
    }

    func loginWithFaceID() {
        faceIDErrorMessage = ""

        if isStaffUsername {
            showFaceIDButton = false
            faceIDErrorMessage = "Face ID login is only available for customers."
            return
        }

        guard let savedEmail = KeychainHelper.shared.read(for: "customerEmail"),
              let savedPassword = KeychainHelper.shared.read(for: "customerPassword"),
              !savedEmail.contains("@staff") else {
            faceIDErrorMessage = "No saved customer login found. Please login once using username and password."
            return
        }

        FaceIDManager.shared.authenticate { success, message in
            if success {
                authVM.login(email: savedEmail, password: savedPassword) { loginSuccess in
                    if loginSuccess {
                        goToCustomer = true
                    }
                }
            } else {
                faceIDErrorMessage = message ?? "Face ID authentication failed."
            }
        }
    }

    func checkSavedCustomerLogin() {
        if isStaffUsername {
            showFaceIDButton = false
            return
        }

        if let savedEmail = KeychainHelper.shared.read(for: "customerEmail"),
           !savedEmail.contains("@staff") {
            showFaceIDButton = true
        } else {
            showFaceIDButton = false
        }
    }
}

#Preview {
    LoginView()
}
