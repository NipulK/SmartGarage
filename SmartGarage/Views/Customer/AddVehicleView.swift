import SwiftUI
import PhotosUI

struct AddVehicleView: View {
    @StateObject private var vehicleService = VehicleService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var color = ""
    @State private var plate = ""
    @State private var vin = ""

    @State private var showScanner = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var scannedText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {

                VStack(spacing: 12) {
                    Image(systemName: "doc.viewfinder")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                        .frame(width: 80, height: 80)
                        .background(Color.blue.opacity(0.12))
                        .cornerRadius(20)

                    Text("Scan Registration")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Scan your vehicle registration document to auto-fill vehicle details.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button {
                        showScanner = true
                    } label: {
                        Label("Scan Document", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label("Choose Image for OCR", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.06))
                .cornerRadius(20)

                if !scannedText.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("SCAN RESULT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)

                        Text("Document text recognized. Vehicle fields were auto-filled where possible.")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.08))
                    .cornerRadius(14)
                }

                Text("VEHICLE DETAILS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                CustomInput(title: "Make", text: $make, placeholder: "Porsche")
                CustomInput(title: "Model", text: $model, placeholder: "911 Carrera S")

                HStack {
                    CustomInput(title: "Year", text: $year, placeholder: "2024")
                    CustomInput(title: "Color", text: $color, placeholder: "Shark Blue")
                }

                CustomInput(title: "License Plate", text: $plate, placeholder: "GTS-911")
                CustomInput(title: "VIN", text: $vin, placeholder: "17-character VIN")

                VStack(spacing: 12) {
                    Image(systemName: "camera.fill")
                        .font(.title)
                        .foregroundColor(.blue)

                    Text("Upload Vehicle Photo")
                        .fontWeight(.semibold)

                    Text("JPG or PNG up to 10MB")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .background(Color.gray.opacity(0.12))
                .cornerRadius(18)
                
                if !vehicleService.errorMessage.isEmpty {
                    Text(vehicleService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    vehicleService.addVehicle(
                        make: make,
                        model: model,
                        year: year,
                        color: color,
                        plate: plate,
                        vin: vin
                    ) { success in
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    Label("Add Vehicle", systemImage: "plus.circle")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
        }
        .navigationTitle("Add New Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showScanner) {
            DocumentScannerView { text in
                scannedText = text
                autoFillVehicleDetails(from: text)
            }
        }
        .onChange(of: selectedPhoto) {
            loadSelectedImageForOCR()
        }
    }

    func loadSelectedImageForOCR() {
        Task {
            guard let selectedPhoto else { return }

            if let data = try? await selectedPhoto.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {

                OCRHelper.recognizeText(from: image) { text in
                    scannedText = text
                    autoFillVehicleDetails(from: text)
                }
            }
        }
    }

    func autoFillVehicleDetails(from text: String) {
        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            let lower = line.lowercased()

            if lower.contains("toyota") {
                make = "Toyota"
            } else if lower.contains("honda") {
                make = "Honda"
            } else if lower.contains("nissan") {
                make = "Nissan"
            } else if lower.contains("bmw") {
                make = "BMW"
            } else if lower.contains("porsche") {
                make = "Porsche"
            } else if lower.contains("mercedes") {
                make = "Mercedes-Benz"
            } else if lower.contains("suzuki") {
                make = "Suzuki"
            }

            if lower.contains("yaris") {
                model = "Yaris"
            } else if lower.contains("civic") {
                model = "Civic"
            } else if lower.contains("corolla") {
                model = "Corolla"
            } else if lower.contains("swift") {
                model = "Swift"
            } else if lower.contains("aqua") {
                model = "Aqua"
            } else if lower.contains("wagon r") {
                model = "Wagon R"
            } else if lower.contains("911") {
                model = "911 Carrera S"
            }

            if let yearMatch = line.range(
                of: #"19[0-9]{2}|20[0-9]{2}"#,
                options: .regularExpression
            ) {
                year = String(line[yearMatch])
            }

            if lower.contains("white") {
                color = "White"
            } else if lower.contains("black") {
                color = "Black"
            } else if lower.contains("blue") {
                color = "Blue"
            } else if lower.contains("red") {
                color = "Red"
            } else if lower.contains("silver") {
                color = "Silver"
            } else if lower.contains("grey") || lower.contains("gray") {
                color = "Gray"
            }

            if lower.contains("plate") ||
                lower.contains("registration") ||
                lower.contains("reg no") ||
                lower.contains("vehicle no") {

                plate = line
                    .replacingOccurrences(of: "Plate", with: "")
                    .replacingOccurrences(of: "Registration", with: "")
                    .replacingOccurrences(of: "Reg No", with: "")
                    .replacingOccurrences(of: "Vehicle No", with: "")
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }

            if lower.contains("vin") ||
                lower.contains("chassis") ||
                line.count == 17 {

                vin = line
                    .replacingOccurrences(of: "VIN", with: "")
                    .replacingOccurrences(of: "Chassis", with: "")
                    .replacingOccurrences(of: ":", with: "")
                    .trimmingCharacters(in: .whitespaces)
            }
        }
    }
}

struct CustomInput: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundColor(.gray)

            TextField(placeholder, text: $text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
    }
}

#Preview {
    NavigationStack {
        AddVehicleView()
    }
}
