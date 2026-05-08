import SwiftUI

struct EditVehicleView: View {

    let vehicle: Vehicle

    @StateObject private var vehicleService = VehicleService()
    @Environment(\.dismiss) private var dismiss

    @State private var make: String
    @State private var model: String
    @State private var year: String
    @State private var color: String
    @State private var plate: String
    @State private var vin: String

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _make = State(initialValue: vehicle.make)
        _model = State(initialValue: vehicle.model)
        _year = State(initialValue: vehicle.year)
        _color = State(initialValue: vehicle.color)
        _plate = State(initialValue: vehicle.plate)
        _vin = State(initialValue: vehicle.vin)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                Text("Edit Vehicle")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VehicleEditTextField(title: "Make", text: $make)
                VehicleEditTextField(title: "Model", text: $model)
                VehicleEditTextField(title: "Year", text: $year)
                VehicleEditTextField(title: "Color", text: $color)
                VehicleEditTextField(title: "Plate Number", text: $plate)
                VehicleEditTextField(title: "VIN", text: $vin)

                if !vehicleService.errorMessage.isEmpty {
                    Text(vehicleService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button {
                    updateVehicle()
                } label: {
                    if vehicleService.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Update Vehicle")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(14)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Edit Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }

    func updateVehicle() {
        guard let vehicleId = vehicle.id else {
            vehicleService.errorMessage = "Vehicle ID not found."
            return
        }

        vehicleService.updateVehicle(
            vehicleId: vehicleId,
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
    }
}

struct VehicleEditTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .padding()
            .background(Color.white)
            .cornerRadius(14)
    }
}

#Preview {
    EditVehicleView(
        vehicle: Vehicle(
            userId: "1",
            make: "Toyota",
            model: "Yaris",
            year: "2020",
            color: "White",
            plate: "ABC-1234",
            vin: "VIN12345",
            createdAt: Date()
        )
    )
}
