//
//  Examples.swift
//  Kontrolka
//
//  Příklady použití API - POUZE PRO REFERENCI, NEPOUŽÍVAT V PRODUKCI
//

import SwiftUI
import SwiftData

// MARK: - Vytvoření testovacích dat

extension TrackedItem {
    static func createSampleData(in context: ModelContext) {
        let samples = [
            TrackedItem(
                title: "STK - Škoda Octavia",
                category: .vehicle,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
                note: "Nutné objednať termín 2 týdny předem"
            ),
            TrackedItem(
                title: "Povinné ručení",
                category: .insurance,
                dueDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())!
            ),
            TrackedItem(
                title: "Revize komína",
                category: .homeMaintenance,
                dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
                note: "Kontakt: 123 456 789"
            ),
            TrackedItem(
                title: "Záruka na pračku",
                category: .warranty,
                dueDate: Calendar.current.date(byAdding: .month, value: 6, to: Date())!
            ),
            TrackedItem(
                title: "Řidičský průkaz",
                category: .document,
                dueDate: Calendar.current.date(byAdding: .year, value: 2, to: Date())!
            ),
            TrackedItem(
                title: "Dálniční známka",
                category: .vehicle,
                dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!
            )
        ]
        
        for item in samples {
            context.insert(item)
        }
    }
}

// MARK: - Dotazy nad daty

extension ModelContext {
    // Získat všechny položky podle urgence
    func itemsByUrgency() -> [TrackedItem] {
        let descriptor = FetchDescriptor<TrackedItem>(
            sortBy: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]
        )
        
        do {
            return try fetch(descriptor)
        } catch {
            print("Chyba při načítání položek: \(error)")
            return []
        }
    }
    
    // Získat položky konkrétní kategorie
    func items(for category: Category) -> [TrackedItem] {
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]
        )
        
        do {
            return try fetch(descriptor)
        } catch {
            print("Chyba při načítání položek: \(error)")
            return []
        }
    }
    
    // Získat položky vypršející v příštích X dnech
    func itemsExpiringSoon(days: Int) -> [TrackedItem] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now)!
        
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { item in
                item.dueDate >= now && item.dueDate <= futureDate
            },
            sortBy: [SortDescriptor(\TrackedItem.dueDate, order: .forward)]
        )
        
        do {
            return try fetch(descriptor)
        } catch {
            print("Chyba při načítání položek: \(error)")
            return []
        }
    }
    
    // Získat již vypršené položky
    func expiredItems() -> [TrackedItem] {
        let now = Date()
        
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { $0.dueDate < now },
            sortBy: [SortDescriptor(\TrackedItem.dueDate, order: .reverse)]
        )
        
        do {
            return try fetch(descriptor)
        } catch {
            print("Chyba při načítání položek: \(error)")
            return []
        }
    }
}

// MARK: - Příklad preview s daty

#Preview("Seznam s daty") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TrackedItem.self, configurations: config)
    let context = container.mainContext
    
    // Vytvoř testovací data
    TrackedItem.createSampleData(in: context)
    
    return ContentView()
        .modelContainer(container)
}

// MARK: - Příklady použití NotificationManager

/*
// Naplánovat notifikace pro položku
Task {
    await NotificationManager.shared.scheduleNotifications(for: item)
}

// Zrušit notifikace pro položku
Task {
    await NotificationManager.shared.cancelNotifications(for: item)
}

// Požádat o oprávnění
Task {
    let granted = await NotificationManager.shared.requestAuthorization()
    if granted {
        print("Notifikace povoleny")
    }
}

// Zrušit všechny notifikace
NotificationManager.shared.cancelAllNotifications()
*/

// MARK: - Příklady použití CalendarManager

/*
// Exportovat položku do kalendáře
Task {
    do {
        // Nejdřív požádat o oprávnění
        let hasAccess = await CalendarManager.shared.requestAccess()
        
        guard hasAccess else {
            print("Přístup k kalendáři zamítnut")
            return
        }
        
        // Pak exportovat
        try await CalendarManager.shared.exportToCalendar(item: item)
        print("Úspěšně exportováno do kalendáře")
    } catch {
        print("Chyba při exportu: \(error)")
    }
}
*/

// MARK: - Možná budoucí rozšíření (NENÍ V MVP)

// 1. Filtrování podle kategorie
/*
struct ContentView: View {
    @State private var selectedCategory: Category? = nil
    
    var filteredItems: [TrackedItem] {
        if let category = selectedCategory {
            return items.filter { $0.category == category }
        }
        return items
    }
}
*/

// 2. Vyhledávání
/*
struct ContentView: View {
    @State private var searchText = ""
    
    var filteredItems: [TrackedItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
}
*/

// 3. Opakující se události
/*
extension TrackedItem {
    var recurringInterval: RecurringInterval?
    
    enum RecurringInterval: String, Codable {
        case yearly = "Ročně"
        case monthly = "Měsíčně"
    }
    
    func createRecurringCopy() -> TrackedItem {
        let newDueDate: Date
        
        switch recurringInterval {
        case .yearly:
            newDueDate = Calendar.current.date(byAdding: .year, value: 1, to: dueDate)!
        case .monthly:
            newDueDate = Calendar.current.date(byAdding: .month, value: 1, to: dueDate)!
        case .none:
            newDueDate = dueDate
        }
        
        return TrackedItem(
            title: title,
            category: category,
            dueDate: newDueDate,
            note: note
        )
    }
}
*/

// 4. Widget data provider
/*
import WidgetKit

struct WidgetDataProvider {
    static func getUpcomingItems(limit: Int = 3) -> [TrackedItem] {
        // Load items from SwiftData container
        // Return sorted by dueDate
        []
    }
}
*/

// 5. Export do CSV
/*
extension TrackedItem {
    static func exportToCSV(items: [TrackedItem]) -> String {
        var csv = "Název,Kategorie,Datum vypršení,Poznámka\n"
        
        for item in items {
            let title = item.title.replacingOccurrences(of: ",", with: ";")
            let category = item.category.rawValue
            let date = item.dueDate.formatted(date: .abbreviated, time: .omitted)
            let note = (item.note ?? "").replacingOccurrences(of: ",", with: ";")
            
            csv += "\(title),\(category),\(date),\(note)\n"
        }
        
        return csv
    }
}
*/

// 6. OCR pro čtení data z fotky (Vision framework)
/*
import Vision

extension AddEditItemView {
    func extractDateFromImage(_ image: UIImage) async -> Date? {
        guard let cgImage = image.cgImage else { return nil }
        
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["cs-CZ"]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results else { return nil }
            
            for observation in observations {
                guard let candidate = observation.topCandidates(1).first else { continue }
                
                // Hledat datum ve formátu DD.MM.YYYY nebo DD/MM/YYYY
                if let date = parseDate(from: candidate.string) {
                    return date
                }
            }
        } catch {
            print("OCR error: \(error)")
        }
        
        return nil
    }
    
    private func parseDate(from string: String) -> Date? {
        let dateFormatters = [
            "dd.MM.yyyy",
            "dd/MM/yyyy",
            "dd-MM-yyyy"
        ].map { format -> DateFormatter in
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "cs_CZ")
            return formatter
        }
        
        for formatter in dateFormatters {
            if let date = formatter.date(from: string) {
                return date
            }
        }
        
        return nil
    }
}
*/
