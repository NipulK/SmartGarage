import SwiftUI

struct CustomerHomeView: View {
    @StateObject private var vehicleService = VehicleService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                
                HStack {
                    Image(systemName: "line.3.horizontal")
                    Text("SmartGarage")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "bell")
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Hello, Alex Rivera")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Your vehicle is in good hands today.")
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("VEHICLE IN SERVICE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Porsche 911 Carrera S")
                                .font(.headline)
                            Text("Service ID: #SG-992-042")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        VStack {
                            Text("EST.")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text("14:30 PM")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text("DIAGNOSTIC PHASE")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    ProgressView(value: 0.65)
                    
                    HStack {
                        InfoBox(icon: "slider.horizontal.3", title: "TYPE", value: "Full Service")
                        InfoBox(icon: "gearshape", title: "EXPERT", value: "Marc L.")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(22)
                .shadow(color: .gray.opacity(0.15), radius: 8)
                
                HStack {
                    Button {
                        
                    } label: {
                        Label("Book Service", systemImage: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        
                    } label: {
                        Label("View History", systemImage: "clock.arrow.circlepath")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                }
                
                HStack {
                    Text("My Vehicles")
                        .font(.headline)
                    Spacer()
                    Text("Add New")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        if vehicleService.isLoading {
                            ProgressView()
                                .padding()
                        } else if vehicleService.vehicles.isEmpty {
                            Text("No vehicles added yet")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(vehicleService.vehicles) { vehicle in
                                VehicleCard(
                                    name: "\(vehicle.make) \(vehicle.model)",
                                    plate: vehicle.plate
                                )
                            }
                        }
                    }
                }
                
                if !vehicleService.errorMessage.isEmpty {
                    Text(vehicleService.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Text("Recent Updates")
                    .font(.headline)
                
                UpdateRow(title: "Oil Filter Replaced", time: "Today, 10:45 AM")
                UpdateRow(title: "Brake Fluid Check", time: "Today, 09:12 AM")
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            vehicleService.fetchVehicles()
        }
    }
}

struct InfoBox: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(14)
    }
}

struct VehicleCard: View {
    let name: String
    let plate: String
    
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 180, height: 100)
                .overlay(
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                )
            
            Text(name)
                .fontWeight(.bold)
            Text(plate)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

struct UpdateRow: View {
    let title: String
    let time: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 4, height: 45)
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                Text(time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(14)
    }
}

#Preview {
    CustomerHomeView()
}
