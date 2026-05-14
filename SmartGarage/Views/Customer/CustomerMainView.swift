import SwiftUI
import FirebaseAuth

struct CustomerMainView: View {

    @Binding var isCustomerLoggedIn: Bool
    @State private var selectedTab = 0
    @State private var showLogoutConfirmation = false
    @State private var logoutErrorMessage = ""

    init(isCustomerLoggedIn: Binding<Bool> = .constant(true)) {
        self._isCustomerLoggedIn = isCustomerLoggedIn
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerHomeView {
                showLogoutConfirmation = true
            }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            CustomerBookingView(selectedTab: $selectedTab)
                .tabItem { Label("Booking", systemImage: "wrench.fill") }
                .tag(1)

            CustomerGarageView(selectedTab: $selectedTab)
                .tabItem { Label("Garage", systemImage: "car.fill") }
                .tag(2)

            CustomerActivityView()
                .tabItem { Label("Activity", systemImage: "clock.fill") }
                .tag(3)

            CustomerProfileView {
                showLogoutConfirmation = true
            }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            Button {
                showLogoutConfirmation = true
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                    .background(Color.white.opacity(0.92))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .accessibilityLabel("Back")
            }
            .padding(.leading, 16)
            .padding(.top, 54)
        }
        .alert("Logout Customer Account?", isPresented: $showLogoutConfirmation) {
            Button("Stay Logged In", role: .cancel) { }

            Button("Logout", role: .destructive) {
                logoutCustomer()
            }
        } message: {
            Text("Are you sure you want to logout and return to the login screen?")
        }
        .alert("Logout Failed", isPresented: Binding(
            get: { !logoutErrorMessage.isEmpty },
            set: { if !$0 { logoutErrorMessage = "" } }
        )) {
            Button("OK", role: .cancel) {
                logoutErrorMessage = ""
            }
        } message: {
            Text(logoutErrorMessage)
        }
    }

    private func logoutCustomer() {
        do {
            try Auth.auth().signOut()
            isCustomerLoggedIn = false
        } catch {
            logoutErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    CustomerMainView()
}
