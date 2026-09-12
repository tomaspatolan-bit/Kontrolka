//
//  TrackedThing.swift
//  Kontrolka
//
//  „Věc", kterou uživatel sleduje u asset kategorií (Vozidlo, Domácnost, Mazlíček)
//  — např. konkrétní auto „Škoda Octavia". Sdružuje víc termínů (TrackedItem):
//  STK, dálniční známka, přezutí… Ploché kategorie (Doklad, Pojištění, Záruka,
//  Ostatní) věci nepoužívají a mají položky přímo (thing == nil).
//

import Foundation
import SwiftData

@Model
final class TrackedThing {
    var id: UUID
    var name: String
    var category: Category
    var createdAt: Date

    // Smazání věci smaže i její termíny.
    @Relationship(deleteRule: .cascade, inverse: \TrackedItem.thing)
    var items: [TrackedItem]

    init(
        id: UUID = UUID(),
        name: String,
        category: Category,
        createdAt: Date = Date(),
        items: [TrackedItem] = []
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.createdAt = createdAt
        self.items = items
    }

    /// Nejbližší (nejnaléhavější) termín věci — pro souhrn ve widgetu/kartě.
    var nearestItem: TrackedItem? {
        items.min(by: { $0.dueDate < $1.dueDate })
    }
}
