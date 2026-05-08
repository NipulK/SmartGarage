import SwiftUI

struct StaffMainView: View {
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

            StaffProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    StaffMainView()
}
