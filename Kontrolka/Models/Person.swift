//
//  Person.swift
//  Kontrolka
//
//  Osoba (uživatel = „primary"). Vlastní osobní doklady (TrackedItem kategorie
//  Doklad). Do budoucna = člen rodiny → víc Person záznamů + CloudKit sdílení.
//
//  Model je záměrně CloudKit-friendly (relace optional, atributy s defaulty,
//  žádné unique) — viz milník rodina.
//

import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID
    var name: String
    var birthDateISO: String
    var isPrimary: Bool
    var createdAt: Date

    // Osobní doklady. Smazání osoby smaže i její doklady.
    @Relationship(deleteRule: .cascade, inverse: \TrackedItem.person)
    var documents: [TrackedItem]

    init(
        id: UUID = UUID(),
        name: String = "",
        birthDateISO: String = "",
        isPrimary: Bool = false,
        createdAt: Date = Date(),
        documents: [TrackedItem] = []
    ) {
        self.id = id
        self.name = name
        self.birthDateISO = birthDateISO
        self.isPrimary = isPrimary
        self.createdAt = createdAt
        self.documents = documents
    }

    var birthDate: Date? { Profile.birthDate(fromISO: birthDateISO) }
}
