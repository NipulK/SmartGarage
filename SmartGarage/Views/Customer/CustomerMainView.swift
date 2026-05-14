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
        NavigationStack {
            TabView(selection: $selectedTab) {

                CustomerHomeView(
                    showsTopBarBackButton: true
                ) {
                    requestLogout()
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

                CustomerBookingView(
                    selectedTab: $selectedTab,
                    showsTopBarBackButton: false
                ) {
                    requestLogout()
                }
                .tabItem {
                    Label("Booking", systemImage: "wrench.fill")
                }
                .tag(1)

                CustomerGarageView(
                    selectedTab: $selectedTab,
                    showsTopBarBackButton: false
                ) {
                    requestLogout()
                }
                .tabItem {
                    Label("Garage", systemImage: "car.fill")
                }
                .tag(2)

                CustomerActivityView(
                    selectedTab: $selectedTab,
                    showsTopBarBackButton: false
                ) {
                    requestLogout()
                }
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
                .tag(3)

                CustomerProfileView(
                    showsTopBarBackButton: false
                ) {
                    requestLogout()
                }
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
            }
            .navigationBarBackButtonHidden(true)
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

    private func requestLogout() {
        showLogoutConfirmation = true
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
