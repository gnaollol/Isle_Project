//
//  CalendarService.swift
//  Isle_Project
//
//  Created by Gian Lardizabal on 10/29/26.
//

import EventKit
import SwiftUI

struct UpcomingEvent: Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let location: String?
    let color: Color

    init(_ event: EKEvent) {
        id = "\(event.calendarItemIdentifier)-\(event.startDate.timeIntervalSince1970)"
        title = event.title ?? "Untitled"
        start = event.startDate
        end = event.endDate
        location = event.location
        color = Color(nsColor: event.calendar.color)
    }

    var subtitle: String {
        let time = Calendar.current.isDateInToday(start)
            ? start.formatted(date: .omitted, time: .shortened)
            : start.formatted(.dateTime.weekday(.abbreviated).hour().minute())

        if let location, !location.isEmpty {
            return "\(time) · \(location)"
        }
        let length = Duration.seconds(end.timeIntervalSince(start))
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
        return "\(time) · \(length)"
    }
}

@Observable
final class CalendarService {
    var upcoming: [UpcomingEvent] = []
    var hasAccess = EKEventStore.authorizationStatus(for: .event) == .fullAccess

    @ObservationIgnored private let store = EKEventStore()
    @ObservationIgnored private var observer: NSObjectProtocol?
    init() {
        observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: store,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.reload()
            }
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func load() async {
        if !hasAccess {
            hasAccess = (try? await store.requestFullAccessToEvents()) ?? false
        }
        reload()
    }

    func reload() {
        guard hasAccess,
              let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) else { return }

        let predicate = store.predicateForEvents(withStart: Date(), end: weekFromNow, calendars: nil)
        upcoming = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }
            .prefix(3)
            .map { UpcomingEvent($0) }
    }
}
    
    


