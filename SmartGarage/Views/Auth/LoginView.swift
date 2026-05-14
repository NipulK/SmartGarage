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
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            
            if isLoginReady {
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            Spacer()
            
            NavigationLink("", destination: CustomerMainView(isCustomerLoggedIn: $goToCustomer), isActive: $goToCustomer)
            NavigationLink("", destination: StaffMainView(isStaffLoggedIn: $goToStaff), isActive: $goToStaff)
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
