//
//  TrackedItem.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import Foundation
import SwiftData

enum Category: String, Codable, CaseIterable {
    case vehicle = "Vozidlo"
    case insurance = "Pojištění"
    case homeMaintenance = "Domácnost"
    case pet = "Mazlíček"
    case warranty = "Záruka"
    case document = "Doklad"
    case other = "Ostatní"

    var defaultReminderDays: [Int] {
        switch self {
        case .vehicle, .insurance, .homeMaintenance, .pet:
            return [30, 7, 1]
        case .warranty, .document, .other:
            return [7]
        }
    }

    /// Kategorie s hierarchií „věc → termíny" (např. konkrétní auto se sadou termínů).
    /// Ostatní kategorie mají položky ploché (bez rodiče).
    var usesThings: Bool {
        switch self {
        case .vehicle, .homeMaintenance, .pet:
            return true
        case .insurance, .warranty, .document, .other:
            return false
        }
    }

    /// Návrhy podkategorií (jen jako štítek/seskupení — nic nepředvyplňují).
    /// Uživatel může vybrat z návrhů nebo napsat vlastní text.
    var subcategorySuggestions: [String] {
        switch self {
        case .vehicle:
            return ["STK", "Dálniční známka", "Povinné ručení", "Havarijní pojištění", "Přezutí pneu", "Rozvody", "Výměna oleje"]
        case .insurance:
            return ["Životní", "Úrazové", "Nemovitost", "Cestovní"]
        case .homeMaintenance:
            return ["Revize kotle", "Revize komína", "Hasicí přístroj", "Revize elektro", "Pojištění nemovitosti"]
        case .pet:
            return ["Očkování", "Odčervení", "Veterinární prohlídka", "Čip"]
        case .warranty:
            return ["Elektronika", "Spotřebič", "Nářadí", "Nábytek"]
        case .document:
            return ["Občanský průkaz", "Cestovní pas", "Řidičský průkaz", "Zdravotní průkaz", "Zbrojní průkaz", "Očkovací průkaz", "ISIC"]
        case .other:
            return []
        }
    }
}

@Model
final class TrackedItem {
    var id: UUID
    var title: String
    var category: Category
    var subcategory: String?
    var dueDate: Date
    var note: String?
    var photoData: Data?
    var customReminderDays: [Int]?
    var createdAt: Date
    var updatedAt: Date

    // Rodičovská „věc" u asset kategorií (Vozidlo/Domácnost/Mazlíček); jinak nil.
    var thing: TrackedThing?

    // Vlastník u osobních dokladů (kategorie Doklad); jinak nil.
    var person: Person?

    init(
        id: UUID = UUID(),
        title: String,
        category: Category,
        subcategory: String? = nil,
        dueDate: Date,
        note: String? = nil,
        photoData: Data? = nil,
        customReminderDays: [Int]? = nil,
        thing: TrackedThing? = nil,
        person: Person? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.subcategory = subcategory
        self.dueDate = dueDate
        self.note = note
        self.photoData = photoData
        self.customReminderDays = customReminderDays
        self.thing = thing
        self.person = person
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var reminderDays: [Int] {
        customReminderDays ?? category.defaultReminderDays
    }
}
