import Foundation
import LocalAuthentication

class FaceIDManager {

    static let shared = FaceIDManager()

    func authenticate(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Login to SmartGarage using Face ID"
            ) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, "Face ID failed. Please try again or use password login.")
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, "Face ID not available. Please use password login.")
            }
        }
    }
}
