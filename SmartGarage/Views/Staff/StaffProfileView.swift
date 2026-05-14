import SwiftUI
import FirebaseAuth

struct StaffProfileView: View {

    var onLogoutRequested: () -> Void = { }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    StaffTopBar(title: "SmartGarage Staff", onBack: onLogoutRequested) {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                    }

                    VStack(spacing: 12) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 90))
                            .foregroundColor(.blue)

                        Text("Marcus")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Senior Service Advisor")
                            .foregroundColor(.gray)

                        Text(Auth.auth().currentUser?.email ?? "staff@smartgarage.com")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(22)

                    VStack(spacing: 14) {
                        StaffProfileOption(
                            icon: "person.fill",
                            title: "Staff ID",
                            value: "STF-001"
                        )

                        StaffProfileOption(
                            icon: "wrench.and.screwdriver.fill",
                            title: "Department",
                            value: "Vehicle Service"
                        )

                        StaffProfileOption(
                            icon: "phone.fill",
                            title: "Contact",
                            value: "+94 77 123 4567"
                        )

                        StaffProfileOption(
                            icon: "clock.fill",
                            title: "Shift",
                            value: "08:00 AM - 05:00 PM"
                        )
                    }

                    Button {
                        onLogoutRequested()
                    } label: {
                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .cornerRadius(14)
                    }
                }
                .padding()
            }
            .navigationTitle("Staff Profile")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StaffProfileOption: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 38, height: 38)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(value)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

#Preview {
    StaffProfileView()
}
