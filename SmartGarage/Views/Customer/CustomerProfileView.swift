import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CustomerProfileView: View {
    @State private var darkMode = false
    @StateObject private var vehicleService = VehicleService()
    @StateObject private var bookingService = BookingService()

    @State private var fullName = "Customer"
    @State private var username = ""
    @State private var phone = ""
    @State private var email = Auth.auth().currentUser?.email ?? ""
    @State private var profileErrorMessage = ""
    @State private var isLoadingProfile = false

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

                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(displayContact)
                            .foregroundColor(.gray)

                        HStack(spacing: 20) {
                            ProfileStat(
                                title: "Vehicles",
                                value: "\(vehicleService.vehicles.count)"
                            )
                            ProfileStat(
                                title: "Services",
                                value: "\(bookingService.bookings.count)"
                            )
                            ProfileStat(
                                title: "Completed",
                                value: "\(completedServiceCount)"
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(22)

                    if isLoadingProfile {
                        ProgressView("Loading profile...")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                    }

                    if !profileErrorMessage.isEmpty {
                        Text(profileErrorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                    }

                    VStack(spacing: 0) {
                        ProfileDetailLine(title: "Full Name", value: displayName)
                        ProfileDetailLine(title: "Username", value: username)
                        ProfileDetailLine(title: "Email", value: email)
                        ProfileDetailLine(title: "Phone", value: phone)
                    }
                    .background(Color.white)
                    .cornerRadius(18)

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
            .onAppear {
                loadProfile()
                vehicleService.fetchVehicles()
                bookingService.fetchBookings()
            }
        }
    }

    private var displayName: String {
        if !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return fullName
        }

        if !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return username
        }

        return "Customer"
    }

    private var displayContact: String {
        if !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return phone
        }

        if !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return email
        }

        return "No contact details"
    }

    private var completedServiceCount: Int {
        bookingService.bookings.filter {
            $0.status.lowercased() == "completed"
        }.count
    }

    private func loadProfile() {
        guard let user = Auth.auth().currentUser else {
            profileErrorMessage = "User not logged in."
            return
        }

        isLoadingProfile = true
        profileErrorMessage = ""
        email = user.email ?? email

        Firestore.firestore()
            .collection("users")
            .document(user.uid)
            .getDocument { snapshot, error in
                DispatchQueue.main.async {
                    isLoadingProfile = false

                    if let error {
                        profileErrorMessage = error.localizedDescription
                        return
                    }

                    let data = snapshot?.data()
                    fullName = data?["fullName"] as? String ?? ""
                    username = data?["username"] as? String ?? ""
                    phone = data?["phone"] as? String ?? ""
                    email = data?["email"] as? String ?? user.email ?? ""
                }
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

struct ProfileDetailLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()

            Text(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Not added" : value)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .padding()

        Divider()
            .padding(.leading)
    }
}

#Preview {
    CustomerProfileView()
}
