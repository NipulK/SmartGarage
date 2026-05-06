import SwiftUI
import FirebaseCore

@main
struct SmartGarageApp: App {
    
    init() {
        
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
