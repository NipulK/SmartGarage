import Foundation
import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    func requestPermission() {

        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]
            ) { granted, error in

                if let error = error {
                    print(error.localizedDescription)
                }

                print("Permission granted: \(granted)")
            }
    }

    func sendLocalNotification(
        title: String,
        body: String
    ) {

        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current()
            .add(request)
    }
}
