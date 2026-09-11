//
//  ContentView.swift
//  Kontrolka
//
//  Hlavní seznam položek — nyní jako karty (TrackedItemCardView).
//  Přidávání položek se přesunulo do MainTabView (prostřední tlačítko v bottom
//  baru), proto tu už není toolbar tlačítko "+".
//
//  ⚠️ Rekonstruováno podle CLAUDE_CONTEXT.md, neměl jsem tvůj skutečný soubor —
//  slouč s původní verzí, ať nepřijdeš o drobnosti, co tu nejsou popsané.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var items: [TrackedItem]

    var body: some View {
        NavigationStack {
            ZStack {
                // Brand gradient jako nejspodnější vrstva
                BrandGradientBackground()
                    .ignoresSafeArea()
                
                // Obsah na vrchu
                Group {
                    if items.isEmpty {
                        ContentUnavailableView(
                            "Zatím nic nesleduješ",
                            systemImage: "checkmark.circle",
                            description: Text("Přidej první položku tlačítkem dole.")
                        )
                    } else {
                        List {
                            ForEach(items) { item in
                                NavigationLink(value: item) {
                                    TrackedItemCardView(item: item)
                                }
                                .buttonStyle(.plain) // Potlačí automatický chevron NavigationLink
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        delete(item)
                                    } label: {
                                        Label("Smazat", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden) // Prosvítání brand gradientu
                    }
                }
            }
            .navigationTitle("Kontrolka")
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: TrackedItem.self) { item in
                ItemDetailView(item: item, modelContext: modelContext)
            }
        }
    }

    private func delete(_ item: TrackedItem) {
        Task {
            await NotificationManager.shared.cancelNotifications(for: item)
        }
        modelContext.delete(item)
    }
}
