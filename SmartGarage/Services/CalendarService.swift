import Foundation
import EventKit

class CalendarService: ObservableObject {

    private let eventStore = EKEventStore()

    func requestAccessAndAddEvent(
        title: String,
        notes: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Bool, String) -> Void
    ) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }

                if granted {
                    self.addEvent(
                        title: title,
                        notes: notes,
                        startDate: startDate,
                        endDate: endDate,
                        completion: completion
                    )
                } else {
                    completion(false, "Calendar permission denied.")
                }
            }
        }
    }

    private func addEvent(
        title: String,
        notes: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Bool, String) -> Void
    ) {
        let event = EKEvent(eventStore: eventStore)

        event.title = title
        event.notes = notes
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents

        let alarm = EKAlarm(relativeOffset: -3600)
        event.addAlarm(alarm)

        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, "Booking added to Calendar successfully.")
        } catch {
            completion(false, error.localizedDescription)
        }
    }
}
