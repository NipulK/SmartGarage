import Foundation
import EventKit

class CalendarService {

    private let eventStore = EKEventStore()

    func requestAccessAndAddEvent(
        title: String,
        notes: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Bool, String) -> Void
    ) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    self.handleCalendarPermission(
                        granted: granted,
                        error: error,
                        title: title,
                        notes: notes,
                        startDate: startDate,
                        endDate: endDate,
                        completion: completion
                    )
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    self.handleCalendarPermission(
                        granted: granted,
                        error: error,
                        title: title,
                        notes: notes,
                        startDate: startDate,
                        endDate: endDate,
                        completion: completion
                    )
                }
            }
        }
    }

    private func handleCalendarPermission(
        granted: Bool,
        error: Error?,
        title: String,
        notes: String,
        startDate: Date,
        endDate: Date,
        completion: @escaping (Bool, String) -> Void
    ) {
        if let error = error {
            completion(false, error.localizedDescription)
            return
        }

        if granted {
            addEvent(
                title: title,
                notes: notes,
                startDate: startDate,
                endDate: endDate,
                completion: completion
            )
        } else {
            completion(false, "Calendar permission denied. Please allow Calendar access in Settings.")
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
