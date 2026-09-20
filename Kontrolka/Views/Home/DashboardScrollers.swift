//
//  DashboardScrollers.swift
//  Kontrolka
//
//  Widget = JEDEN rámeček (rounded card). Uvnitř něj se vodorovně stránkuje
//  obsah (jedna „stránka" vyplní celý widget, žádné prosakování sousedů),
//  pod obsahem tečky (poslední = „+"). N reálných stránek + „přidat" stránka;
//  „nekonečný" wrap přes velký virtuální rozsah (stránka = index % (počet+1)).
//

import SwiftUI
import SwiftData

struct WrapScroller<Page: View>: View {
    let realCount: Int
    let contentHeight: CGFloat
    let page: (Int) -> Page

    @State private var scrollPos: Int?
    private let virtual = 10_000

    init(
        realCount: Int,
        contentHeight: CGFloat,
        @ViewBuilder page: @escaping (Int) -> Page
    ) {
        self.realCount = realCount
        self.contentHeight = contentHeight
        self.page = page
    }

    // Reálné stránky + 1 „přidat".
    private var total: Int { realCount + 1 }

    private var activeIndex: Int {
        (((scrollPos ?? 0) % total) + total) % total
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(0..<virtual, id: \.self) { i in
                        page(i % total)
                            .containerRelativeFrame(.horizontal)
                            .id(i)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPos)
            .frame(height: contentHeight)

            if total > 1 {
                dots
                    .padding(.top, 12)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.06), radius: 15, y: 6)
        .onAppear {
            guard scrollPos == nil else { return }
            let mid = virtual / 2
            scrollPos = mid - (mid % total) // začni na první reálné stránce
        }
    }

    private var dots: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                if i == realCount {
                    Image(systemName: "plus")
                        .font(.system(size: 8, weight: .black))
                        .foregroundStyle(i == activeIndex ? Color.brandAccent : Color.brandTextSecondary.opacity(0.45))
                } else {
                    Circle()
                        .fill(i == activeIndex ? Color.brandAccent : Color.brandTextSecondary.opacity(0.3))
                        .frame(width: 7, height: 7)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.snappy, value: activeIndex)
    }
}

// MARK: - Ilustrace kategorie

struct CategoryArt: View {
    let category: Category

    var body: some View {
        if let name = category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
        } else {
            Image(systemName: category.iconName)
                .font(.system(size: 36))
                .foregroundStyle(Color.brandAccent)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - „Přidat" stránka (obsah, bez pozadí — pozadí drží widget)

struct AddContent: View {
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 34))
                .foregroundStyle(Color.brandAccent)
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandAccent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Obsah velké karty vozidla (ilustrace vlevo, sloupec termínů vpravo)

struct VehicleThingContent: View {
    let thing: TrackedThing

    private var items: [TrackedItem] {
        thing.items.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image("IllustrationCar")
                .resizable()
                .scaledToFit()
                .frame(width: 110)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 10) {
                Text(thing.name)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)

                if items.isEmpty {
                    Text("Zatím žádný termín")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brandTextSecondary)
                } else {
                    VStack(spacing: 8) {
                        ForEach(items.prefix(4)) { item in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(item.urgency.color)
                                    .frame(width: 7, height: 7)
                                Text(item.title)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.brandTextPrimary)
                                    .lineLimit(1)
                                Spacer(minLength: 6)
                                Text(item.compactDeadline)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(item.urgency.textColor)
                                    .lineLimit(1)
                            }
                        }
                        if items.count > 4 {
                            Text("+\(items.count - 4) dalších")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.brandTextSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Obsah malé karty věci (mazlíček, domácnost): jméno + nejbližší termín

struct SmallThingContent: View {
    let thing: TrackedThing

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CategoryArt(category: thing.category)
                .frame(maxWidth: .infinity)
                .frame(height: 64)

            Text(thing.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .lineLimit(1)

            if let nearest = thing.nearestItem {
                HStack(spacing: 5) {
                    Circle().fill(nearest.urgency.color).frame(width: 7, height: 7)
                    Text("\(nearest.title) · \(nearest.compactDeadline)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(nearest.urgency.textColor)
                        .lineLimit(1)
                }
            } else {
                Text("Zatím žádný termín")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Obsah malé karty ploché položky (doklad, ostatní)

struct SmallItemContent: View {
    let item: TrackedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CategoryArt(category: item.category)
                .frame(maxWidth: .infinity)
                .frame(height: 64)

            Text(item.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .lineLimit(1)

            HStack(spacing: 5) {
                Circle().fill(item.urgency.color).frame(width: 7, height: 7)
                Text(item.compactDeadline)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(item.urgency.textColor)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
