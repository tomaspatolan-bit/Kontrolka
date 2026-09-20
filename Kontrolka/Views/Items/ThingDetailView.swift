//
//  ThingDetailView.swift
//  Kontrolka
//
//  Detail „věci" (např. konkrétního auta): hero + seznam jejích termínů.
//  Otevírá se z widgetu vozidel na Domů a ze seznamu věcí v CategoryDetailView.
//

import SwiftUI
import SwiftData

struct ThingDetailView: View {
    let thing: TrackedThing
    let modelContext: ModelContext

    @Environment(\.dismiss) private var dismiss
    @State private var showingAdd = false
    @State private var showingDeleteAlert = false
    @State private var showingRename = false
    @State private var renameText = ""

    private var items: [TrackedItem] {
        thing.items.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    Text("TERMÍNY")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.brandTextPrimary)
                        .padding(.leading, 4)

                    if items.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(items) { item in
                                NavigationLink(value: item) {
                                    TrackedItemCardView(item: item)
                                }
                                .buttonStyle(PressableCardStyle())
                            }
                        }
                    }

                    addButton
                    deleteButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(thing.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    renameText = thing.name
                    showingRename = true
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.brandAccent)
                }
                .accessibilityLabel("Přejmenovat věc")
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditItemView(modelContext: modelContext, existingThing: thing)
        }
        .alert("Smazat \(thing.name)?", isPresented: $showingDeleteAlert) {
            Button("Zrušit", role: .cancel) {}
            Button("Smazat", role: .destructive) { deleteThing() }
        } message: {
            Text("Smaže se věc i všechny její termíny. Akci nelze vrátit zpět.")
        }
        .alert("Přejmenovat věc", isPresented: $showingRename) {
            TextField("Název", text: $renameText)
            Button("Uložit") { rename() }
            Button("Zrušit", role: .cancel) {}
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 12) {
            illustration
                .frame(height: 140)
                .frame(maxWidth: .infinity)

            HStack {
                Text(thing.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
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
        if let name = thing.category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            Image(systemName: thing.category.iconName)
                .font(.system(size: 56))
                .foregroundStyle(Color.brandAccent)
                .accessibilityHidden(true)
        }
    }

    private var summaryLine: String {
        let count = items.count
        guard count > 0 else { return "Žádné termíny" }
        let soon = items.filter { $0.urgency != .normal }.count
        let word = count == 1 ? "termín" : (count < 5 ? "termíny" : "termínů")
        return soon == 0 ? "\(count) \(word) • klid" : "\(count) \(word) • \(soon) brzy"
    }

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

    private var addButton: some View {
        Button {
            showingAdd = true
        } label: {
            Text("Přidat termín")
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

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash")
                Text("Smazat věc")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.urgencyCriticalText)
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surfaceCardBase)
            )
        }
        .buttonStyle(PressableCardStyle())
    }

    private func rename() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        thing.name = trimmed
        try? modelContext.save()
    }

    private func deleteThing() {
        // Nejdřív zruš notifikace všech termínů, pak smaž věc (cascade smaže položky).
        for item in thing.items {
            Task {
                await NotificationManager.shared.cancelNotifications(for: item)
            }
        }
        modelContext.delete(thing)
        dismiss()
    }
}

// Řádková karta věci pro seznam (CategoryDetailView u asset kategorií).
struct ThingRowCard: View {
    let thing: TrackedThing

    private var nearest: TrackedItem? { thing.nearestItem }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill((nearest?.urgency.color ?? Color.brandAccent).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: thing.category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(nearest?.urgency.color ?? Color.brandAccent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(thing.name)
                    .font(.headline)
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)

                if let nearest {
                    Text("\(nearest.title) · \(nearest.shortDeadline)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(nearest.urgency.textColor)
                        .lineLimit(1)
                } else {
                    Text("Zatím žádný termín")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }
}
