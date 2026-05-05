import SwiftUI

struct StaffMainView: View {
    var body: some View {
        TabView {
            Text("Dashboard")
                .tabItem { Label("Home", systemImage: "house") }

            Text("Bookings")
                .tabItem { Label("Booking", systemImage: "wrench") }

            Text("Activity")
                .tabItem { Label("Activity", systemImage: "clock") }

            Text("Profile")
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
