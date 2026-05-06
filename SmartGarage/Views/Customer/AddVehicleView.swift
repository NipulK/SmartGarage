import SwiftUI

struct AddVehicleView: View {
    @StateObject private var vehicleService = VehicleService()
    @Environment(\.dismiss) private var dismiss
    
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var color = ""
    @State private var plate = ""
    @State private var vin = ""

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
                        print("Scan document later")
                    } label: {
                        Label("Scan Document", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.06))
                .cornerRadius(20)

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
