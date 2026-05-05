import SwiftUI

struct MaintenanceGuideView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("Maintenance Guide")
                .font(.title)
                .fontWeight(.bold)

            Text("Vehicle care tips will be added here.")
                .foregroundColor(.gray)
        }
        .navigationTitle("Maintenance Guide")
    }
}

#Preview {
    MaintenanceGuideView()
}
