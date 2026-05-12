import SwiftUI
import PhotosUI

struct DamageAssessmentView: View {

    @Binding var selectedTab: Int

    @StateObject private var vehicleService = VehicleService()
    @StateObject private var damageService = DamageDetectionService()

    @State private var selectedVehicle = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isLoadingImage = false
    @State private var showResult = false

    @State private var selectedDamageType = "Dent"

    let damageTypes = [
        "Dent",
        "Scratch",
        "Broken Light",
        "Front Bumper Damage",
        "Windshield Crack"
    ]

    init(selectedTab: Binding<Int> = .constant(2)) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("AI Damage Assessment")
                            .font(.title)
                            .fontWeight(.bold)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Text("Upload vehicle photos and get instant AI damage analysis.")
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    vehiclePickerSection
                    damageTypeSection
                    photoUploadSection(
                        containerWidth: max(proxy.size.width - 32, 0)
                    )
                }
                .padding()
                .frame(width: proxy.size.width, alignment: .leading)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            vehicleService.fetchVehicles()
            selectFirstVehicleIfNeeded()
        }
        .onChange(of: vehicleService.vehicles.count) {
            selectFirstVehicleIfNeeded()
        }
        .onChange(of: selectedPhoto) {
            loadSelectedImage()
        }
        .navigationDestination(isPresented: $showResult) {
            DamageResultView(
                selectedTab: $selectedTab,
                damageType: damageService.damageType,
                severity: damageService.severity,
                confidence: damageService.confidence,
                estimatedCost: damageService.estimatedCost,
                vehicleName: damageService.vehicleName,
                selectedImage: selectedImage
            )
        }
    }

    private var vehiclePickerSection: some View {
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
    }

    private var damageTypeSection: some View {
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
    }

    private func photoUploadSection(containerWidth: CGFloat) -> some View {
        let cardPadding: CGFloat = 16
        let previewWidth = max(containerWidth - (cardPadding * 2), 0)

        return VStack(spacing: 18) {
            photoPreview(width: previewWidth)

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label(selectedImage == nil ? "Choose Image" : "Change Image", systemImage: "photo")
                    .fontWeight(.bold)
                    .frame(width: previewWidth)
                    .padding(.vertical)
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(14)
            }

            if !damageService.errorMessage.isEmpty {
                Text(damageService.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .frame(width: previewWidth, alignment: .leading)
            }

            Button {
                scanDamage()
            } label: {
                if damageService.isLoading {
                    ProgressView()
                        .tint(.white)
                        .frame(width: previewWidth)
                        .padding(.vertical)
                } else {
                    Label("Analyze Damage", systemImage: "viewfinder")
                        .fontWeight(.bold)
                        .frame(width: previewWidth)
                        .padding(.vertical)
                }
            }
            .background(canAnalyze ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(14)
            .disabled(!canAnalyze)
        }
        .padding(cardPadding)
        .frame(width: containerWidth)
        .background(Color.white)
        .cornerRadius(24)
        .clipped()
    }

    private func photoPreview(width: CGFloat) -> some View {
        let previewHeight: CGFloat = 220

        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(selectedImage == nil ? 0.08 : 0))

            if isLoadingImage {
                ProgressView("Loading image...")
            } else if let selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: width, height: previewHeight)
                    .clipped()
            } else {
                VStack(spacing: 12) {
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
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
        }
        .frame(width: width, height: previewHeight)
        .cornerRadius(18)
        .clipped()
    }

    private var canAnalyze: Bool {
        selectedImage != nil &&
        !selectedVehicle.isEmpty &&
        !isLoadingImage &&
        !damageService.isLoading
    }

    func loadSelectedImage() {
        Task {
            guard let selectedPhoto else { return }

            await MainActor.run {
                isLoadingImage = true
                damageService.errorMessage = ""
            }

            do {
                guard let data = try await selectedPhoto.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else {
                    await MainActor.run {
                        isLoadingImage = false
                        damageService.errorMessage = "Could not load this image. Please choose another photo."
                    }
                    return
                }

                await MainActor.run {
                    selectedImage = image
                    isLoadingImage = false
                }
            } catch {
                await MainActor.run {
                    isLoadingImage = false
                    damageService.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func selectFirstVehicleIfNeeded() {
        guard selectedVehicle.isEmpty,
              let firstVehicle = vehicleService.vehicles.first else {
            return
        }

        selectedVehicle = firstVehicle.id ?? ""
    }

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
