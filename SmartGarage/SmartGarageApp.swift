import SwiftUI
import FirebaseCore

@main
struct SmartGarageApp: App {
    
    init() {
        
        FirebaseApp.configure()
        
        NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
