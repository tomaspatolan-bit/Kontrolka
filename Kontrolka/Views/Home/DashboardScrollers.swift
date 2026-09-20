//
//  DashboardScrollers.swift
//  Kontrolka
//
//  Vodorovné „nekonečné" wrap scrollery pro widgety na Domů: N reálných karet
//  (věci/položky) + poslední „přidat" dlaždice, pod tím tečky (poslední = „+").
//  Reálná karta = index % (počet+1); přidávat jde i intuitivně scrollem doprava.
//

import SwiftUI
import SwiftData

struct WrapScroller<RealPage: View, AddPage: View>: View {
    let realCount: Int
    let height: CGFloat
    let realPage: (Int) -> RealPage
    let addPage: () -> AddPage

    @State private var scrollPos: Int?
    private let virtual = 10_000

    init(
        realCount: Int,
        height: CGFloat,
        @ViewBuilder realPage: @escaping (Int) -> RealPage,
        @ViewBuilder addPage: @escaping () -> AddPage
    ) {
        self.realCount = realCount
        self.height = height
        self.realPage = realPage
        self.addPage = addPage
    }

    // Reálné karty + 1 „přidat" dlaždice.
    private var total: Int { realCount + 1 }

    private var activeIndex: Int {
        (((scrollPos ?? 0) % total) + total) % total
    }

    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(0..<virtual, id: \.self) { i in
                        let slot = i % total
                        Group {
                            if slot < realCount {
                                realPage(slot)
                            } else {
                                addPage()
                            }
                        }
                        .containerRelativeFrame(.horizontal)
                        .frame(height: height)
                        .id(i)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPos)
            .frame(height: height)

            if total > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<total, id: \.self) { i in
                        if i == realCount {
                            // Poslední tečka = „přidat".
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
        .onAppear {
            guard scrollPos == nil else { return }
            let mid = virtual / 2
            scrollPos = mid - (mid % total) // začni na první reálné kartě
        }
    }
}

// MARK: - Velká karta vozidla (ilustrace vlevo, sloupec termínů vpravo)

struct VehicleThingCard: View {
    let thing: TrackedThing

    private var items: [TrackedItem] {
        thing.items.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image("IllustrationCar")
                .resizable()
                .scaledToFit()
                .frame(width: 116)
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
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.06), radius: 15, y: 6)
    }
}
