//
//  KontrolkaApp.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import SwiftData

@main
struct KontrolkaApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrackedItem.self,
            TrackedThing.self,
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .task {
                migrateOrphanItemsIntoThings()
                ensurePrimaryPersonAndDocuments()
            }
        }
        .modelContainer(sharedModelContainer)
    }

    /// Zajistí primární osobu (uživatele) a jednorázově jí přiřadí existující doklady.
    /// Nová osoba se seedne z @AppStorage profilu (kvůli dřívějším uživatelům).
    @MainActor
    private func ensurePrimaryPersonAndDocuments() {
        let context = sharedModelContainer.mainContext
        let persons = (try? context.fetch(FetchDescriptor<Person>())) ?? []

        let primary: Person
        if let existing = persons.first(where: { $0.isPrimary }) {
            primary = existing
        } else {
            let name = UserDefaults.standard.string(forKey: ProfileStorage.nameKey) ?? ""
            let iso = UserDefaults.standard.string(forKey: ProfileStorage.birthDateKey) ?? ""
            primary = Person(name: name, birthDateISO: iso, isPrimary: true)
            context.insert(primary)
        }

        let key = "didAssignDocumentsToPersonV1"
        if !UserDefaults.standard.bool(forKey: key) {
            let items = (try? context.fetch(FetchDescriptor<TrackedItem>())) ?? []
            for item in items where item.category == .document && item.person == nil {
                item.person = primary
            }
            UserDefaults.standard.set(true, forKey: key)
        }

        try? context.save()
    }

    /// Jednorázová migrace: dřívější ploché položky asset kategorií obalí každou
    /// do vlastní „věci" (název = dosavadní title), ať se po zavedení hierarchie
    /// nic neztratí a objeví se v novém widgetu.
    @MainActor
    private func migrateOrphanItemsIntoThings() {
        let key = "didMigrateThingsV1"
        guard !UserDefaults.standard.bool(forKey: key) else { return }

        let context = sharedModelContainer.mainContext
        if let items = try? context.fetch(FetchDescriptor<TrackedItem>()) {
            for item in items where item.thing == nil && item.category.usesThings {
                let thing = TrackedThing(name: item.title, category: item.category)
                context.insert(thing)
                item.thing = thing
            }
            try? context.save()
        }

        UserDefaults.standard.set(true, forKey: key)
    }
}
