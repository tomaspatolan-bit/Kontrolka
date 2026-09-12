//
//  NotificationManager.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }
    
    func scheduleNotifications(for item: TrackedItem) async {
        // Zrušit staré notifikace pro tuto položku
        await cancelNotifications(for: item)
        
        // Naplánovat nové notifikace
        let calendar = Calendar.current
        let now = Date()
        
        for daysBeforeDue in item.reminderDays {
            guard let notificationDate = calendar.date(byAdding: .day, value: -daysBeforeDue, to: item.dueDate),
                  notificationDate > now else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            
            if daysBeforeDue == 1 {
                content.title = "Zítra vyprší lhůta"
                content.body = item.title
            } else {
                content.title = "\(item.title)"
                content.body = "Vyprší za \(daysBeforeDue) dní"
            }
            
            content.sound = .default
            content.categoryIdentifier = "TRACKED_ITEM_REMINDER"
            content.userInfo = ["itemId": item.id.uuidString]
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "\(item.id.uuidString)-\(daysBeforeDue)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Chyba při plánování notifikace: \(error)")
            }
        }

        // Po naplánování prioritizuj: iOS drží max 64 lokálních notifikací,
        // nad limit je tiše zahazuje. Necháme naplánované jen nejbližší termíny.
        await enforceGlobalLimit()
    }

    /// iOS limit je 64 naplánovaných lokálních notifikací na aplikaci. Když se
    /// blížíme stropu, ponecháme jen `max` nejbližších (podle času spuštění) a
    /// nejvzdálenější zrušíme — položky s bližším termínem tak mají přednost.
    /// (Vědomý mírný „centrální scheduler" — jinak by se nadlimitní notifikace
    /// tiše zahodily.)
    private func enforceGlobalLimit(max: Int = 60) async {
        let center = UNUserNotificationCenter.current()
        let pending = await center.pendingNotificationRequests()
        guard pending.count > max else { return }

        let farFuture = Date.distantFuture
        let sorted = pending.sorted { lhs, rhs in
            let l = (lhs.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() ?? farFuture
            let r = (rhs.trigger as? UNCalendarNotificationTrigger)?.nextTriggerDate() ?? farFuture
            return l < r
        }

        let identifiersToRemove = sorted.dropFirst(max).map { $0.identifier }
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }

    func cancelNotifications(for item: TrackedItem) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        
        let identifiersToRemove = pendingRequests
            .filter { $0.content.userInfo["itemId"] as? String == item.id.uuidString }
            .map { $0.identifier }
        
        center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
