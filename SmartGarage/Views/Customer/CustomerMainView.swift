import SwiftUI
import FirebaseAuth

struct CustomerMainView: View {

    @Binding var isCustomerLoggedIn: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var showLogoutConfirmation = false
    @State private var logoutErrorMessage = ""

    init(isCustomerLoggedIn: Binding<Bool> = .constant(true)) {
        self._isCustomerLoggedIn = isCustomerLoggedIn
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerHomeView(
                showsTopBarBackButton: true
            ) {
                requestLogout()
            }
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            CustomerBookingView(
                selectedTab: $selectedTab,
                showsTopBarBackButton: false
            ) {
                requestLogout()
            }
                .tabItem { Label("Booking", systemImage: "wrench.fill") }
                .tag(1)

            CustomerGarageView(
                selectedTab: $selectedTab,
                showsTopBarBackButton: false
            ) {
                requestLogout()
            }
                .tabItem { Label("Garage", systemImage: "car.fill") }
                .tag(2)

            CustomerActivityView(
                selectedTab: $selectedTab,
                showsTopBarBackButton: false
            ) {
                requestLogout()
            }
                .tabItem { Label("Activity", systemImage: "clock.fill") }
                .tag(3)

            CustomerProfileView(
                showsTopBarBackButton: false
            ) {
                requestLogout()
            }
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
        .navigationBarBackButtonHidden(true)
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
            dismiss()
        } catch {
            logoutErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    CustomerMainView()
}

struct CustomerTopBar<Trailing: View>: View {
    let onBack: () -> Void
    var showsBackButton = true
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: 12) {
            if showsBackButton {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
            }

            Text("SmartGarage")
                .fontWeight(.bold)
                .foregroundColor(.blue)

            Spacer()

            trailing()
        }
    }
}
