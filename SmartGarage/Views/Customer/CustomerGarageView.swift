import SwiftUI

struct CustomerGarageView: View {

    @Binding var selectedTab: Int
    var onLogoutRequested: () -> Void = { }
    var showsTopBarBackButton = true

    init(
        selectedTab: Binding<Int> = .constant(2),
        showsTopBarBackButton: Bool = true,
        onLogoutRequested: @escaping () -> Void = { }
    ) {
        self._selectedTab = selectedTab
        self.showsTopBarBackButton = showsTopBarBackButton
        self.onLogoutRequested = onLogoutRequested
    }

    @StateObject private var vehicleService = VehicleService()

    @State private var selectedVehicle: Vehicle?
    @State private var showDeleteAlert = false
    @State private var successMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    CustomerTopBar(
                        onBack: onLogoutRequested,
                        showsBackButton: showsTopBarBackButton
                    ) {
                        NavigationLink {
                            CustomerProfileView {
                                onLogoutRequested()
                            }
                        } label: {
                            Image(systemName: "person.circle.fill")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Garage")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Manage your vehicles and check vehicle damage using smart tools.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }

                    NavigationLink(destination: AddVehicleView()) {
                        GarageOptionCard(
                            icon: "car.fill",
                            title: "Add New Vehicle",
                            subtitle: "Add vehicle details manually or by scanning document",
                            color: .blue
                        )
                    }

                    NavigationLink(destination: DamageAssessmentView(selectedTab: $selectedTab)) {
                        GarageOptionCard(
                            icon: "camera.viewfinder",
                            title: "AI Damage Assessment",
                            subtitle: "Upload vehicle photos and get damage analysis",
                            color: .orange
                        )
                    }

                    NavigationLink(destination: MaintenanceGuideView()) {
                        GarageOptionCard(
                            icon: "book.closed.fill",
                            title: "Maintenance Guide",
                            subtitle: "View vehicle care tips and maintenance advice",
                            color: .green
                        )
                    }
                    
                    NavigationLink(destination: GarageMapView()) {
                        GarageOptionCard(
                            icon: "map.fill",
                            title: "Garage Location",
                            subtitle: "View garage location and open route in Apple Maps",
                            color: .purple
                        )
                    }

                    HStack {
                        Text("Registered Vehicles")
                            .font(.headline)

                        Spacer()

                        Button {
                            vehicleService.fetchVehicles()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                        }
                    }

                    if vehicleService.isLoading {
                        ProgressView("Loading vehicles...")
                            .padding()
                            .frame(maxWidth: .infinity)
                    } else if vehicleService.vehicles.isEmpty {
                        Text("No registered vehicles yet.")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(16)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(vehicleService.vehicles) { vehicle in
                                RegisteredVehicleRow(
                                    vehicle: vehicle,
                                    onDelete: {
                                        selectedVehicle = vehicle
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                    }

                    if !successMessage.isEmpty {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                    }

                    if !vehicleService.errorMessage.isEmpty {
                        Text(vehicleService.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .onAppear {
                vehicleService.fetchVehicles()
            }
            .alert("Delete Vehicle", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }

                Button("Delete", role: .destructive) {
                    deleteSelectedVehicle()
                }
            } message: {
                Text("Are you sure you want to delete this vehicle?")
            }
        }
    }

    func deleteSelectedVehicle() {
        guard let vehicleId = selectedVehicle?.id else {
            vehicleService.errorMessage = "Vehicle ID not found."
            return
        }

        vehicleService.deleteVehicle(vehicleId: vehicleId) { success in
            if success {
                successMessage = "Vehicle deleted successfully."
                selectedVehicle = nil
            }
        }
    }
}

struct RegisteredVehicleRow: View {
    let vehicle: Vehicle
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "car.fill")
                .foregroundColor(.blue)
                .frame(width: 48, height: 48)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 5) {
                Text("\(vehicle.make) \(vehicle.model)")
                    .font(.headline)
                    .foregroundColor(.black)

                Text("Plate: \(vehicle.plate)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text("Year: \(vehicle.year) • Color: \(vehicle.color)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            NavigationLink {
                EditVehicleView(vehicle: vehicle)
            } label: {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash.fill")
                    .foregroundColor(.red)
                    .padding(10)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .gray.opacity(0.08), radius: 6)
    }
}

struct GarageOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 55, height: 55)
                .background(color)
                .cornerRadius(16)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .gray.opacity(0.12), radius: 8)
    }
}

#Preview {
    CustomerGarageView()
}
