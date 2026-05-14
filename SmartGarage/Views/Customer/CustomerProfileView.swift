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
    @State private var selectedLanguage = "English"

    var showsTopBarBackButton = true
    var onLogoutRequested: () -> Void = { }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    CustomerTopBar(
                        onBack: onLogoutRequested,
                        showsBackButton: showsTopBarBackButton
                    ) {
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
                        NavigationLink {
                            AccountInformationView(
                                fullName: displayName,
                                username: username,
                                email: email,
                                phone: phone
                            )
                        } label: {
                            ProfileRow(icon: "person.fill", title: "Account Information")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            ProfileVehiclesView(
                                vehicles: vehicleService.vehicles
                            )
                        } label: {
                            ProfileRow(icon: "car.fill", title: "My Vehicles")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PaymentMethodsView()
                        } label: {
                            ProfileRow(icon: "creditcard.fill", title: "Payment Methods")
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            NotificationListView(userRole: "customer")
                        } label: {
                            ProfileRow(icon: "bell.fill", title: "Notifications")
                        }
                        .buttonStyle(.plain)
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

                        NavigationLink {
                            LanguageSettingsView(
                                selectedLanguage: $selectedLanguage
                            )
                        } label: {
                            ProfileRow(
                                icon: "globe",
                                title: "Language",
                                value: selectedLanguage
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            HelpSupportView()
                        } label: {
                            ProfileRow(icon: "questionmark.circle.fill", title: "Help & Support")
                        }
                        .buttonStyle(.plain)
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
    var value: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 28)

                Text(title)
                    .fontWeight(.semibold)

                Spacer()

                if let value {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()

            Divider()
                .padding(.leading, 50)
        }
    }
}

struct AccountInformationView: View {
    let fullName: String
    let username: String
    let email: String
    let phone: String

    var body: some View {
        List {
            Section("Personal Details") {
                ProfileDetailLine(title: "Full Name", value: fullName)
                ProfileDetailLine(title: "Username", value: username)
                ProfileDetailLine(title: "Email", value: email)
                ProfileDetailLine(title: "Phone", value: phone)
            }

            Section("Account") {
                Label("Customer account", systemImage: "person.badge.shield.checkmark")
                Label("SmartGarage member", systemImage: "checkmark.seal.fill")
            }
        }
        .navigationTitle("Account Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileVehiclesView: View {
    let vehicles: [Vehicle]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                NavigationLink {
                    AddVehicleView()
                } label: {
                    Label("Add New Vehicle", systemImage: "plus.circle.fill")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }

                if vehicles.isEmpty {
                    Text("No vehicles added yet.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(16)
                } else {
                    ForEach(vehicles) { vehicle in
                        NavigationLink {
                            EditVehicleView(vehicle: vehicle)
                        } label: {
                            ProfileVehicleCard(vehicle: vehicle)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Vehicles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileVehicleCard: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .foregroundColor(.blue)
                .frame(width: 46, height: 46)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(vehicle.make) \(vehicle.model)")
                    .font(.headline)

                Text("Plate: \(vehicle.plate)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("\(vehicle.year) • \(vehicle.color)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct PaymentMethodsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Add payment details at the garage counter after service confirmation.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(16)

                VStack(alignment: .leading, spacing: 14) {
                    Label("Cash payments accepted", systemImage: "banknote.fill")
                    Label("Card payments available at pickup", systemImage: "creditcard.fill")
                    Label("Invoice issued after completion", systemImage: "doc.text.fill")
                }
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSettingsView: View {
    @Binding var selectedLanguage: String

    private let languages = [
        "English",
        "Sinhala",
        "Tamil"
    ]

    var body: some View {
        List {
            Section("App Language") {
                ForEach(languages, id: \.self) { language in
                    Button {
                        selectedLanguage = language
                    } label: {
                        HStack {
                            Text(language)
                                .foregroundColor(.black)

                            Spacer()

                            if selectedLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpSupportView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Need help?")
                        .font(.headline)

                    Text("Contact SmartGarage support for booking, vehicle, service, and damage report questions.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)

                VStack(spacing: 0) {
                    SupportLine(icon: "phone.fill", title: "Phone", value: "+94 11 234 5678")
                    SupportLine(icon: "envelope.fill", title: "Email", value: "support@smartgarage.com")
                    SupportLine(icon: "clock.fill", title: "Hours", value: "Mon - Sat, 9:00 AM - 6:00 PM")
                }
                .background(Color.white)
                .cornerRadius(16)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Answers")
                        .font(.headline)

                    Text("Use Activity to track service status, Garage to manage vehicles, and Notifications to view garage messages.")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportLine: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Spacer()
        }
        .padding()

        Divider()
            .padding(.leading, 56)
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
