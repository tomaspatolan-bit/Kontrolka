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
}

@Model
final class TrackedItem {
    var id: UUID
    var title: String
    var category: Category
    var dueDate: Date
    var note: String?
    var photoData: Data?
    var customReminderDays: [Int]?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        category: Category,
        dueDate: Date,
        note: String? = nil,
        photoData: Data? = nil,
        customReminderDays: [Int]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.dueDate = dueDate
        self.note = note
        self.photoData = photoData
        self.customReminderDays = customReminderDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var reminderDays: [Int] {
        customReminderDays ?? category.defaultReminderDays
    }
}
