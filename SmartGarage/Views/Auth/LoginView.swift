import SwiftUI

struct LoginView: View {
    @StateObject private var authVM = AuthViewModel()
    
    @State private var email = ""
    @State private var password = ""
    @State private var goToCustomer = false
    @State private var goToStaff = false

    private var isLoginReady: Bool {
        password.count == 6 && password.allSatisfy { $0.isNumber }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            AppLogoMark(size: 112, cornerRadius: 26, padding: 7)
            
            Text("SmartGarage")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Customer username", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onChange(of: password) { newValue in
                    let digits = newValue.filter { $0.isNumber }
                    let limitedDigits = String(digits.prefix(6))

                    if limitedDigits != newValue {
                        password = limitedDigits
                    }
                }
            
            if !authVM.errorMessage.isEmpty {
                Label(authVM.errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal)
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
            
            Spacer()
        }
        .fullScreenCover(isPresented: $goToCustomer) {
            CustomerMainView(isCustomerLoggedIn: $goToCustomer)
        }
        .fullScreenCover(isPresented: $goToStaff) {
            StaffMainView(isStaffLoggedIn: $goToStaff)
        }
    }
    
    
    func login() {

        var loginEmail = ""

        // STAFF LOGIN
        if email.lowercased().hasPrefix("s_") {

            loginEmail = "\(email.lowercased())@staff.smartgarage.com"

        } else {

            // CUSTOMER LOGIN
            loginEmail = "\(email.lowercased())@smartgarage.com"
        }

        authVM.login(email: loginEmail, password: password) { success in

            if success {

                if email.lowercased().hasPrefix("s_") {

                    goToStaff = true

                } else {

                    goToCustomer = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
