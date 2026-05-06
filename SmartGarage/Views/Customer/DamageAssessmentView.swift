import SwiftUI
import PhotosUI

struct DamageAssessmentView: View {

    @StateObject private var vehicleService = VehicleService()
    @StateObject private var damageService = DamageDetectionService()

    @State private var selectedVehicle = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showResult = false

    @State private var selectedDamageType = "Dent"

    let damageTypes = [
        "Dent",
        "Scratch",
        "Broken Light",
        "Front Bumper Damage",
        "Windshield Crack"
    ]

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                VStack(alignment: .leading, spacing: 8) {

                    Text("AI Damage Assessment")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Upload vehicle photos and get instant AI damage analysis.")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // VEHICLE PICKER
                VStack(alignment: .leading, spacing: 12) {

                    Text("SELECT VEHICLE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    if vehicleService.vehicles.isEmpty {

                        Text("No vehicles found. Please add a vehicle first.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            .cornerRadius(14)

                    } else {

                        Picker("Vehicle", selection: $selectedVehicle) {

                            ForEach(vehicleService.vehicles) { vehicle in

                                Text("\(vehicle.make) \(vehicle.model)")
                                    .tag(vehicle.id ?? "")
                            }
                        }
                        .pickerStyle(.menu)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(14)
                    }
                }

                // DAMAGE TYPE PICKER
                VStack(alignment: .leading, spacing: 12) {

                    Text("DAMAGE TYPE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    Picker("Damage Type", selection: $selectedDamageType) {

                        ForEach(damageTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)
                }

                // IMAGE SECTION
                VStack(spacing: 22) {

                    if let selectedImage {

                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(18)

                    } else {

                        Image(systemName: "camera.badge.ellipsis")
                            .font(.system(size: 42))
                            .foregroundColor(.blue)
                            .frame(width: 90, height: 90)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(25)

                        Text("Upload Vehicle Photo")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text("Capture the damaged area clearly for better AI accuracy.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {

                        Label("Choose Image", systemImage: "photo")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(14)
                    }

                    if !damageService.errorMessage.isEmpty {

                        Text(damageService.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    Button {

                        scanDamage()

                    } label: {

                        if damageService.isLoading {

                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()

                        } else {

                            Label("Analyze Damage", systemImage: "viewfinder")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(
                        selectedImage == nil || selectedVehicle.isEmpty
                        ? Color.gray
                        : Color.blue
                    )
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .disabled(selectedImage == nil || selectedVehicle.isEmpty)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(24)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))

        .onAppear {

            vehicleService.fetchVehicles()
        }

        .onChange(of: vehicleService.vehicles.count) {

            if selectedVehicle.isEmpty,
               let firstVehicle = vehicleService.vehicles.first {

                selectedVehicle = firstVehicle.id ?? ""
            }
        }

        .onChange(of: selectedPhoto) {

            loadSelectedImage()
        }

        .navigationDestination(isPresented: $showResult) {

            DamageResultView()
        }
    }

    // LOAD IMAGE
    func loadSelectedImage() {

        Task {

            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {

                await MainActor.run {

                    selectedImage = image
                }
            }
        }
    }

    // ANALYZE DAMAGE
    func scanDamage() {

        guard let selectedImage else { return }

        guard let vehicle = vehicleService.vehicles.first(where: {
            $0.id == selectedVehicle
        }) else {

            damageService.errorMessage = "Please select a vehicle."
            return
        }

        damageService.analyzeDamage(
            image: selectedImage,
            vehicleId: vehicle.id ?? "",
            vehicleName: "\(vehicle.make) \(vehicle.model)",
            damageType: selectedDamageType
        ) { success in

            if success {

                showResult = true
            }
        }
    }
}

#Preview {

    NavigationStack {

        DamageAssessmentView()
    }
}
