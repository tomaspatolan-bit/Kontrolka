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

extension TrackedItem {
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
