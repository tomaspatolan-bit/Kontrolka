//
//  CalendarManager.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import Foundation
import EventKit

@MainActor
final class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func requestAccess() async -> Bool {
        do {
            return try await eventStore.requestFullAccessToEvents()
        } catch {
            return false
        }
    }
    
    enum ExportResult {
        case created
        case updated
    }

    /// Exportuje/aktualizuje událost. Dedup přes `item.calendarEventID` — opakovaný
    /// export už existující událost aktualizuje místo vytvoření duplicity.
    @discardableResult
    func exportToCalendar(item: TrackedItem) async throws -> ExportResult {
        // Existuje už událost pro tuto položku?
        let existing = item.calendarEventID.flatMap { eventStore.event(withIdentifier: $0) }

        let event = existing ?? EKEvent(eventStore: eventStore)
        event.title = item.title
        event.startDate = item.dueDate
        event.endDate = item.dueDate
        event.isAllDay = true
        event.notes = item.note
        if existing == nil {
            event.calendar = eventStore.defaultCalendarForNewEvents
            // Připomínka den předem (jen u nové události).
            event.addAlarm(EKAlarm(relativeOffset: -86400))
        }

        try eventStore.save(event, span: .thisEvent)
        item.calendarEventID = event.eventIdentifier
        return existing == nil ? .created : .updated
    }
}
