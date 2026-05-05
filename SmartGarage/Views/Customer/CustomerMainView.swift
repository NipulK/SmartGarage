import SwiftUI

struct CustomerMainView: View {
    var body: some View {
        TabView {
            CustomerHomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            Text("Booking")
                .tabItem { Label("Booking", systemImage: "wrench.fill") }

            Text("Garage")
                .tabItem { Label("Garage", systemImage: "car.fill") }

            Text("Activity")
                .tabItem { Label("Activity", systemImage: "clock.fill") }

            Text("Profile")
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}
