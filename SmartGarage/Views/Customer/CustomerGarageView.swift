import SwiftUI

struct CustomerGarageView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HStack {
                        Image(systemName: "line.3.horizontal")
                        Text("SmartGarage")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
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

                    NavigationLink(destination: DamageAssessmentView()) {
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
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
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
