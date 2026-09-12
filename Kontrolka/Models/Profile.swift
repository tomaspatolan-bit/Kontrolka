//
//  Profile.swift
//  Kontrolka
//
//  Uživatelský profil (jméno + datum narození) uložený v @AppStorage.
//  Záměrně jednoduché; do budoucna je tu prostor rozšířit na rodinu/skupiny.
//

import Foundation

/// Klíče @AppStorage pro profil (sdílené napříč onboarding / Domů / Profil).
enum ProfileStorage {
    static let nameKey = "profileName"
    static let birthDateKey = "profileBirthDate"
}

/// Pomocné převody a formátování profilu.
enum Profile {
    static func birthDate(fromISO iso: String) -> Date? {
        guard !iso.isEmpty else { return nil }
        return ISO8601DateFormatter().date(from: iso)
    }

    static func iso(from date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    static func age(from birthDate: Date) -> Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }

    static func formattedBirthDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "cs_CZ")
        formatter.dateFormat = "d. M. yyyy"
        return formatter.string(from: date)
    }

    static func initial(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "?" : String(trimmed.prefix(1)).uppercased()
    }

    /// České skloňování: 1 rok / 2–4 roky / 5+ let.
    static func yearsWord(_ age: Int) -> String {
        switch age {
        case 1: return "rok"
        case 2...4: return "roky"
        default: return "let"
        }
    }

    /// „32 let" z data narození (nebo nil, když datum chybí).
    static func ageText(fromISO iso: String) -> String? {
        guard let date = birthDate(fromISO: iso) else { return nil }
        let years = age(from: date)
        return "\(years) \(yearsWord(years))"
    }
}
