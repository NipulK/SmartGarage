import SwiftUI

struct CustomerProfileView: View {
    @State private var darkMode = false
    var onLogoutRequested: () -> Void = { }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    CustomerTopBar(onBack: onLogoutRequested) {
                        NavigationLink {
                            NotificationListView(userRole: "customer")
                        } label: {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundColor(.black)
                        }
                    }

                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 85))
                            .foregroundColor(.blue)

                        Text("Alex Rivera")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("+1 (555) 345-9087")
                            .foregroundColor(.gray)

                        HStack(spacing: 20) {
                            ProfileStat(title: "Vehicles", value: "2")
                            ProfileStat(title: "Services", value: "14")
                            ProfileStat(title: "Rating", value: "4.9")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(22)

                    VStack(spacing: 0) {
                        ProfileRow(icon: "person.fill", title: "Account Settings")
                        ProfileRow(icon: "car.fill", title: "My Vehicles")
                        ProfileRow(icon: "creditcard.fill", title: "Payment Methods")
                        ProfileRow(icon: "bell.fill", title: "Notifications")
                    }
                    .background(Color.white)
                    .cornerRadius(18)

                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)

                            Text("Dark Mode")
                                .fontWeight(.semibold)

                            Spacer()

                            Toggle("", isOn: $darkMode)
                                .labelsHidden()
                        }
                        .padding()

                        Divider()

                        ProfileRow(icon: "globe", title: "Language")
                        ProfileRow(icon: "questionmark.circle.fill", title: "Help & Support")
                    }
                    .background(Color.white)
                    .cornerRadius(18)

                    Button {
                        onLogoutRequested()
                    } label: {
                        Text("Logout")
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
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct ProfileStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 28)

                Text(title)
                    .fontWeight(.semibold)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()
                .padding(.leading, 50)
        }
    }
}

#Preview {
    CustomerProfileView()
}
