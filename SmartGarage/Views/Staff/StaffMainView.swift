import SwiftUI
import FirebaseAuth

struct StaffMainView: View {
    @Binding var isStaffLoggedIn: Bool
    @State private var showLogoutConfirmation = false
    @State private var logoutErrorMessage = ""

    init(isStaffLoggedIn: Binding<Bool> = .constant(true)) {
        self._isStaffLoggedIn = isStaffLoggedIn
    }

    var body: some View {
        TabView {
            StaffDashboardView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            StaffBookingView(initialTab: "All")
                .tabItem {
                    Label("Booking", systemImage: "wrench")
                }

            StaffActivityView()
                .tabItem {
                    Label("Activity", systemImage: "clock")
                }

            StaffProfileView {
                showLogoutConfirmation = true
            }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading) {
            Button {
                showLogoutConfirmation = true
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
            .padding(.leading, 16)
            .padding(.top, 10)
        }
        .alert("Logout Staff Account?", isPresented: $showLogoutConfirmation) {
            Button("Stay Logged In", role: .cancel) { }

            Button("Logout", role: .destructive) {
                logoutStaff()
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

    private func logoutStaff() {
        do {
            try Auth.auth().signOut()
            isStaffLoggedIn = false
        } catch {
            logoutErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    StaffMainView()
}
