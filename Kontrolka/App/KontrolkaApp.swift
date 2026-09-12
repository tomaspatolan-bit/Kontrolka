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
            .task { migrateOrphanItemsIntoThings() }
        }
        .modelContainer(sharedModelContainer)
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
