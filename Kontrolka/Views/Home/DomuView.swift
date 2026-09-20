//
//  DomuView.swift
//  Kontrolka
//
//  Domovská obrazovka (dashboard) — dle Figma sekce Navigace / Domů.
//

import SwiftUI
import SwiftData

// MARK: - Přehled kategorie pro widget

struct CategorySummary {
    let category: Category
    let count: Int
    let nearest: TrackedItem?
}

// MARK: - Domů

struct DomuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var items: [TrackedItem]
    @Query(sort: \TrackedThing.createdAt, order: .forward) private var allThings: [TrackedThing]
    @Query(filter: #Predicate<Person> { $0.isPrimary }) private var primaryPersons: [Person]
    @Namespace private var categoryNS
    @State private var revealed = false
    @State private var addCategory: Category?
    private static var hasRevealedOnce = false

    // Pevné výšky widgetů — prázdné i plné (s tečkami) musí mít stejnou výšku.
    private let vehicleWidgetHeight: CGFloat = 220
    private let smallWidgetHeight: CGFloat = 176

    private func summary(for category: Category) -> CategorySummary {
        let inCategory = items.filter { $0.category == category }
        return CategorySummary(
            category: category,
            count: inCategory.count,
            nearest: inCategory.min(by: { $0.dueDate < $1.dueDate })
        )
    }

    /// Počet dokladů (pro dlaždici na uvítací kartě)
    private var documentCount: Int {
        items.filter { $0.category == .document }.count
    }

    /// Sledovaná vozidla (věci) — pro hlavní scrollovací widget.
    private var vehicleThings: [TrackedThing] {
        allThings.filter { $0.category == .vehicle }
    }

    // Hlavní widget vozidel: stránkování přes věci + „přidat" stránka, vše v jednom rámečku.
    private var vehicleScroller: some View {
        WrapScroller(realCount: vehicleThings.count, height: vehicleWidgetHeight) { slot in
            if slot < vehicleThings.count {
                NavigationLink(value: vehicleThings[slot]) {
                    VehicleThingContent(thing: vehicleThings[slot])
                }
                .buttonStyle(.plain)
            } else {
                Button { addCategory = .vehicle } label: {
                    AddContent(title: "Přidat vozidlo")
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Malý widget asset kategorie: prázdné → default karta (klepni pro přidání), jinak scroller.
    @ViewBuilder
    private func assetSmallWidget(_ category: Category, addTitle: String) -> some View {
        if allThings.contains(where: { $0.category == category }) {
            smallThingScroller(category, addTitle: addTitle)
        } else {
            Button { addCategory = category } label: {
                SmallCategoryWidget(summary: summary(for: category))
            }
            .buttonStyle(PressableCardStyle())
            .frame(height: smallWidgetHeight)
        }
    }

    // Doklady: prázdné → default karta, jinak scroller přes položky.
    @ViewBuilder
    private var documentWidget: some View {
        if items.contains(where: { $0.category == .document }) {
            smallItemScroller(.document, addTitle: "Přidat doklad")
        } else {
            Button { addCategory = .document } label: {
                SmallCategoryWidget(summary: summary(for: .document))
            }
            .buttonStyle(PressableCardStyle())
            .frame(height: smallWidgetHeight)
        }
    }

    // Malý scroller přes věci kategorie (mazlíček, domácnost).
    private func smallThingScroller(_ category: Category, addTitle: String) -> some View {
        let categoryThings = allThings.filter { $0.category == category }
        return WrapScroller(realCount: categoryThings.count, height: smallWidgetHeight) { slot in
            if slot < categoryThings.count {
                NavigationLink(value: categoryThings[slot]) {
                    SmallThingContent(thing: categoryThings[slot])
                }
                .buttonStyle(.plain)
            } else {
                Button { addCategory = category } label: {
                    AddContent(title: addTitle)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // Malý scroller přes ploché položky kategorie (doklad, ostatní).
    private func smallItemScroller(_ category: Category, addTitle: String) -> some View {
        let categoryItems = items.filter { $0.category == category }
        return WrapScroller(realCount: categoryItems.count, height: smallWidgetHeight) { slot in
            if slot < categoryItems.count {
                NavigationLink(value: categoryItems[slot]) {
                    SmallItemContent(item: categoryItems[slot])
                }
                .buttonStyle(.plain)
            } else {
                Button { addCategory = category } label: {
                    AddContent(title: addTitle)
                }
                .buttonStyle(.plain)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BrandGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Logo
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityLabel("Kontrolka")
                            .appearReveal(revealed, delay: 0)

                        Group {
                            if let person = primaryPersons.first {
                                NavigationLink(value: person) {
                                    GreetingCard(documentCount: documentCount)
                                }
                                .buttonStyle(PressableCardStyle())
                            } else {
                                GreetingCard(documentCount: documentCount)
                            }
                        }
                        .appearReveal(revealed, delay: 0.06)

                        // Widgety nebo prázdný stav
                        if items.isEmpty {
                            emptyState
                                .appearReveal(revealed, delay: 0.12)
                        } else {
                            VStack(spacing: 12) {
                                Group {
                                    if vehicleThings.isEmpty {
                                        Button { addCategory = .vehicle } label: {
                                            VehicleWidget(summary: summary(for: .vehicle))
                                        }
                                        .buttonStyle(PressableCardStyle())
                                        .frame(height: vehicleWidgetHeight)
                                    } else {
                                        vehicleScroller
                                    }
                                }
                                .appearReveal(revealed, delay: 0.12)

                                HStack(spacing: 13) {
                                    assetSmallWidget(.pet, addTitle: "Přidat mazlíčka")
                                    assetSmallWidget(.homeMaintenance, addTitle: "Přidat dům")
                                }
                                .appearReveal(revealed, delay: 0.18)

                                HStack(spacing: 13) {
                                    documentWidget
                                    categoryLink(.other) {
                                        SmallCategoryWidget(summary: summary(for: .other))
                                    }
                                    .frame(height: smallWidgetHeight)
                                }
                                .appearReveal(revealed, delay: 0.24)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16) // spodní rezerva obsahu (místo pro tab bar drží TabView)
                }
            }
            .navigationDestination(for: Category.self) { category in
                CategoryDetailView(category: category)
                    .zoomTransition(id: category, in: categoryNS)
            }
            .navigationDestination(for: TrackedThing.self) { thing in
                ThingDetailView(thing: thing, modelContext: modelContext)
            }
            .navigationDestination(for: TrackedItem.self) { item in
                ItemDetailView(item: item, modelContext: modelContext)
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailView(person: person, modelContext: modelContext)
            }
            .sheet(item: $addCategory) { category in
                AddEditItemView(modelContext: modelContext, initialCategory: category)
            }
            .onAppear(perform: triggerReveal)
        }
    }

    private func triggerReveal() {
        if Self.hasRevealedOnce {
            revealed = true
        } else {
            revealed = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                revealed = true
                Self.hasRevealedOnce = true
            }
        }
    }

    private func categoryLink<Content: View>(
        _ category: Category,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationLink(value: category) {
            content()
        }
        .buttonStyle(PressableCardStyle())
        .zoomSource(id: category, in: categoryNS)
    }

    // Prázdný stav = pozvánka. Stejná mřížka kategorií jako plný stav, ale
    // každá karta otevře přidání s předvybranou kategorií (žádná falešná data),
    // takže uživatel hned vidí, co může sledovat, a je to rovnou vstup do přidání.
    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Co chceš hlídat?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                Text("Vyber kategorii a přidej první termín — o připomenutí se postará Kontrolka.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 4)

            inviteFeatured(.vehicle)

            HStack(spacing: 13) {
                inviteSmall(.pet)
                inviteSmall(.homeMaintenance)
            }

            HStack(spacing: 13) {
                inviteSmall(.document)
                inviteSmall(.other)
            }
        }
    }

    // Featured pozvánka (vozidlo) — stejné proporce jako VehicleWidget.
    private func inviteFeatured(_ category: Category) -> some View {
        Button {
            addCategory = category
        } label: {
            VStack(spacing: 10) {
                HStack {
                    Text(category.widgetTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.brandTextPrimary)
                    Spacer()
                    addPill
                }

                categoryIllustration(category)
                    .frame(height: 130)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surfaceCardBase)
            )
            .shadow(color: .black.opacity(0.06), radius: 15, y: 6)
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("Přidat kategorii \(category.widgetTitle)")
    }

    // Malá pozvánka — stejné proporce jako SmallCategoryWidget.
    private func inviteSmall(_ category: Category) -> some View {
        Button {
            addCategory = category
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    categoryIllustration(category)
                        .frame(maxWidth: .infinity)
                        .frame(height: 78)
                    plusBadge
                }

                Text(category.widgetTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)

                Text("Přidat")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.brandAccent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surfaceCardBase)
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel("Přidat kategorii \(category.widgetTitle)")
    }

    @ViewBuilder
    private func categoryIllustration(_ category: Category) -> some View {
        if let name = category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: category.iconName)
                .font(.system(size: 40))
                .foregroundStyle(Color.brandAccent)
        }
    }

    // „Přidat" pill pro featured kartu
    private var addPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
            Text("Přidat")
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(Color.brandAccent)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(Color.brandAccent.opacity(0.12)))
    }

    // Kruhové „+" v rohu ilustrace u malých karet
    private var plusBadge: some View {
        Image(systemName: "plus")
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(Color.white)
            .padding(6)
            .background(Circle().fill(Color.brandAccent))
    }
}

// Otevírání add sheetu z pozvánkových karet přes .sheet(item:)
extension Category: Identifiable {
    public var id: String { rawValue }
}

// MARK: - GreetingCard

struct GreetingCard: View {
    let documentCount: Int

    @Query(filter: #Predicate<Person> { $0.isPrimary }) private var primaryPersons: [Person]
    private var name: String { primaryPersons.first?.name ?? "" }
    private var birthDateISO: String { primaryPersons.first?.birthDateISO ?? "" }

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.brandAccent)
                        if name.isEmpty {
                            Image(systemName: "person.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.white)
                        } else {
                            Text(Profile.initial(from: name))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(name.isEmpty ? "Vítejte zpět" : name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.brandTextPrimary)
                            .lineLimit(1)
                        Text("Osobní karta")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                }

                HStack(spacing: 8) {
                    StatTile(label: "Věk", value: Profile.ageText(fromISO: birthDateISO) ?? "—")
                    StatTile(label: "Doklady", value: "\(documentCount)")
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.07), radius: 8, y: 8)
    }
}

private struct StatTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(Color.brandTextSecondary)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.75))
        )
    }
}

// MARK: - VehicleWidget (featured)

struct VehicleWidget: View {
    let summary: CategorySummary

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Vaše vozidlo")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                Spacer()
                Text("\(summary.count) \(summary.count == 1 ? "položka" : "položky")")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandTextSecondary)
            }

            Image("IllustrationCar")
                .resizable()
                .scaledToFit()
                .frame(height: 144)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            if let nearest = summary.nearest {
                HStack(spacing: 6) {
                    Circle()
                        .fill(nearest.urgency.color)
                        .frame(width: 7, height: 7)
                    Text("\(nearest.title) vyprší \(nearest.shortDeadline)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(nearest.urgency.textColor)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                }
            } else {
                WidgetEmptyStatus()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.06), radius: 15, y: 6)
    }
}

// MARK: - Malý widget kategorie

struct SmallCategoryWidget: View {
    let summary: CategorySummary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                illustration
                    .frame(maxWidth: .infinity)
                    .frame(height: 78)

                if summary.nearest != nil {
                    Circle()
                        .fill((summary.nearest?.urgency.color ?? Color.brandAccent).opacity(0.9))
                        .frame(width: 8, height: 8)
                }
            }

            Text(summary.category.widgetTitle)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)

            if let nearest = summary.nearest {
                HStack(spacing: 5) {
                    Circle()
                        .fill(nearest.urgency.color)
                        .frame(width: 7, height: 7)
                    Text("\(nearest.title) · \(nearest.shortDeadline)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(nearest.urgency.textColor)
                        .lineLimit(1)
                }
            } else {
                WidgetEmptyStatus()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }

    @ViewBuilder
    private var illustration: some View {
        if let name = summary.category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            Image(systemName: summary.category.iconName)
                .font(.system(size: 40))
                .foregroundStyle(Color.brandAccent)
                .accessibilityHidden(true)
        }
    }
}

private struct WidgetEmptyStatus: View {
    var body: some View {
        Text("Nic nesledováno")
            .font(.system(size: 13))
            .foregroundStyle(Color.brandTextSecondary)
            .lineLimit(1)
    }
}

#Preview {
    DomuView()
        .modelContainer(for: TrackedItem.self, inMemory: true)
}
