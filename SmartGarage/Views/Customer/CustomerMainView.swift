import SwiftUI

struct CustomerMainView: View {
    var body: some View {
        TabView {
            CustomerHomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            
            CustomerBookingView()
                .tabItem { Label("Booking", systemImage: "wrench.fill") }

            CustomerGarageView()
                .tabItem { Label("Garage", systemImage: "car.fill") }

            CustomerActivityView()
                .tabItem { Label("Activity", systemImage: "clock.fill") }

            CustomerProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
    
}
