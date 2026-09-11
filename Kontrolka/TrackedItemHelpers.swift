//
//  TrackedItemHelpers.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import Foundation

enum Urgency: Equatable {
    case critical  // < 7 dní
    case warning   // < 30 dní
    case normal    // 30+ dní
    
    /// Barva pro ikony, tečky a další plochy (brand color)
    var color: Color {
        switch self {
        case .critical: return .urgencyCriticalFill
        case .warning: return .urgencyWarningFill
        case .normal: return .urgencyNormalFill
        }
    }
    
    /// Barva pro text s lepším kontrastem (brand color)
    var textColor: Color {
        switch self {
        case .critical: return .urgencyCriticalText
        case .warning: return .urgencyWarningText
        case .normal: return .urgencyNormalText
        }
    }
}

extension Category {
    /// Název ilustrace v asset katalogu (nil = kategorie nemá vlastní ilustraci)
    var illustrationName: String? {
        switch self {
        case .vehicle: return "IllustrationCar"
        case .pet: return "IllustrationPet"
        case .homeMaintenance: return "IllustrationHouse"
        case .document: return "IllustrationDocuments"
        case .other: return "IllustrationOther"
        case .insurance, .warranty: return nil
        }
    }

    /// Titulek widgetu na Domů (může se lišit od rawValue)
    var widgetTitle: String {
        switch self {
        case .document: return "Doklady"
        default: return rawValue
        }
    }
}

extension TrackedItem {
    /// Kompaktní text termínu pro widgety ("za 5 dní", "zítra", "po termínu")
    var shortDeadline: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        if days < 0 { return "po termínu" }
        if days == 0 { return "dnes" }
        if days == 1 { return "zítra" }
        return "za \(days) dní"
    }

    var urgency: Urgency {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        
        if daysRemaining < 7 {
            return .critical
        } else if daysRemaining < 30 {
            return .warning
        } else {
            return .normal
        }
    }
    
    var dueDateFormatted: String {
        let calendar = Calendar.current
        let daysRemaining = calendar.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        
        if daysRemaining < 0 {
            return "Vypršelo před \(abs(daysRemaining)) dny"
        } else if daysRemaining == 0 {
            return "Vyprší dnes"
        } else if daysRemaining == 1 {
            return "Vyprší zítra"
        } else if daysRemaining <= 30 {
            return "Vyprší za \(daysRemaining) dní"
        } else {
            return dueDate.formatted(date: .abbreviated, time: .omitted)
        }
    }
}
