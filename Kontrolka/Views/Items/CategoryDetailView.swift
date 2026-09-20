//
//  CategoryDetailView.swift
//  Kontrolka
//
//  Detail kategorie: hero ilustrace + název + shrnutí a seznam termínů dané
//  kategorie. Otevírá se klepnutím na widget na Domů. Bez modelu "věc" —
//  pracuje přímo s TrackedItem filtrovanými podle kategorie.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: Category

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var allItems: [TrackedItem]
    @Query(sort: \TrackedThing.createdAt, order: .forward) private var allThings: [TrackedThing]
    @State private var showingAdd = false

    private var items: [TrackedItem] {
        allItems.filter { $0.category == category }
    }

    private var things: [TrackedThing] {
        allThings.filter { $0.category == category }
    }

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    Text(category.usesThings ? "VĚCI" : "TERMÍNY")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.brandTextPrimary)
                        .padding(.leading, 4)

                    if category.usesThings {
                        if things.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 12) {
                                ForEach(things) { thing in
                                    NavigationLink(value: thing) {
                                        ThingRowCard(thing: thing)
                                    }
                                    .buttonStyle(PressableCardStyle())
                                }
                            }
                        }
                    } else {
                        if items.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 12) {
                                ForEach(items) { item in
                                    NavigationLink(value: item) {
                                        TrackedItemCardView(item: item)
                                    }
                                    .buttonStyle(PressableCardStyle())
                                    .transition(.move(edge: .top).combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: items.count)
                        }
                    }

                    addButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(category.widgetTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationDestination(for: TrackedItem.self) { item in
            ItemDetailView(item: item, modelContext: modelContext)
        }
        .sheet(isPresented: $showingAdd) {
            AddEditItemView(modelContext: modelContext, initialCategory: category, itemToEdit: nil)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 12) {
            illustration
                .frame(height: 150)
                .frame(maxWidth: .infinity)

            HStack {
                Text(category.widgetTitle)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                Spacer()
                Text(summaryLine)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }

    @ViewBuilder
    private var illustration: some View {
        if let name = category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            Image(systemName: category.iconName)
                .font(.system(size: 64))
                .foregroundStyle(Color.brandAccent)
                .accessibilityHidden(true)
        }
    }

    private var summaryLine: String {
        guard !items.isEmpty else { return "Žádné termíny" }
        let soon = items.filter { $0.urgency != .normal }.count
        let word = items.count == 1 ? "termín" : (items.count < 5 ? "termíny" : "termínů")
        if soon == 0 {
            return "\(items.count) \(word) • klid"
        }
        return "\(items.count) \(word) • \(soon) brzy"
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Zatím žádné termíny")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
            Text("Přidej první termín tlačítkem níže.")
                .font(.system(size: 13))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    // MARK: - Add

    private var addButton: some View {
        Button {
            showingAdd = true
        } label: {
            Text(category.usesThings ? "Přidat věc" : "Přidat termín")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.brandAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
        }
        .buttonStyle(.plain)
    }
}
