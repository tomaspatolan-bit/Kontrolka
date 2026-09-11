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
    
    func exportToCalendar(item: TrackedItem) async throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = item.title
        event.startDate = item.dueDate
        event.endDate = item.dueDate
        event.isAllDay = true
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        if let note = item.note {
            event.notes = note
        }
        
        // Přidej připomínku den před událostí
        let alarm = EKAlarm(relativeOffset: -86400) // -24 hodin
        event.addAlarm(alarm)
        
        try eventStore.save(event, span: .thisEvent)
    }
}
