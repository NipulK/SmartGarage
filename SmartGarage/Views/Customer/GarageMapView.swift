import SwiftUI
import MapKit

struct GarageMapView: View {

    private let garageCoordinate = CLLocationCoordinate2D(
        latitude: 6.98190,
        longitude: 80.09970
    )

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 7.2083, longitude: 79.8358),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $cameraPosition) {
                Marker("SmartGarage", coordinate: garageCoordinate)
            }
            .frame(height: 420)

            VStack(alignment: .leading, spacing: 14) {
                Text("SmartGarage Location")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Find the garage location and open directions using Apple Maps.")
                    .foregroundColor(.gray)

                Button {
                    openAppleMaps()
                } label: {
                    Label("Open in Apple Maps", systemImage: "map.fill")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
            }
            .padding()
            .background(Color.white)
        }
        .navigationTitle("Garage Map")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }

    func openAppleMaps() {
        let placemark = MKPlacemark(coordinate: garageCoordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "SmartGarage"

        mapItem.openInMaps(
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}

#Preview {
    NavigationStack {
        GarageMapView()
    }
}
