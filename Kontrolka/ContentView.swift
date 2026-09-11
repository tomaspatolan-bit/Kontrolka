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
                            PrehledSummaryCard(total: items.count, soon: soonCount)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                            Text("VŠECHNY TERMÍNY")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.brandTextSecondary)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 12, leading: 20, bottom: 4, trailing: 16))

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
            .navigationTitle("Přehled")
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: TrackedItem.self) { item in
                ItemDetailView(item: item, modelContext: modelContext)
            }
        }
    }

    /// Počet položek, které potřebují pozornost brzy (critical + warning)
    private var soonCount: Int {
        items.filter { $0.urgency != .normal }.count
    }

    private func delete(_ item: TrackedItem) {
        Task {
            await NotificationManager.shared.cancelNotifications(for: item)
        }
        modelContext.delete(item)
    }
}

// Souhrnná karta v Přehledu (dle Figma SummaryCard)
struct PrehledSummaryCard: View {
    let total: Int
    let soon: Int

    private var subtitle: String {
        if soon == 0 {
            return "Vše je v klidu, žádný termín nehoří."
        } else if soon == 1 {
            return "Jedna věc potřebuje pozornost brzy, zbytek je klidný."
        } else {
            return "\(soon) věci potřebují pozornost brzy."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(total) \(total == 1 ? "věc sledována" : "věcí sledováno")")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(Color.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }
}
