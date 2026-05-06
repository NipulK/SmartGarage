import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var goToCustomer = false
    @State private var goToStaff = false

    var body: some View {
        VStack(spacing: 20) {

            Spacer()

            Text("SmartGarage")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("C_username or S_username", text: $username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)

            Button("Login") {
                login()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)

            Spacer()

            NavigationLink("", destination: CustomerMainView(), isActive: $goToCustomer)
            NavigationLink("", destination: StaffMainView(), isActive: $goToStaff)
        }
    }
    

    func login() {
        if username.uppercased().hasPrefix("C_") {
            goToCustomer = true
        } else if username.uppercased().hasPrefix("S_") {
            goToStaff = true
        }
    }
}
