import SwiftUI

struct CustomerMainView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CustomerHomeView()
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

            CustomerProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(4)
        }
    }
}

#Preview {
    CustomerMainView()
}
