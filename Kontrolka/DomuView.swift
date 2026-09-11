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
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var items: [TrackedItem]

    private func summary(for category: Category) -> CategorySummary {
        let inCategory = items.filter { $0.category == category }
        return CategorySummary(
            category: category,
            count: inCategory.count,
            nearest: inCategory.min(by: { $0.dueDate < $1.dueDate })
        )
    }

    /// Počet položek, které potřebují pozornost brzy (critical + warning)
    private var soonCount: Int {
        items.filter { $0.urgency != .normal }.count
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

                        GreetingCard(totalCount: items.count, soonCount: soonCount)

                        // Widgety (klepnutí → detail kategorie)
                        VStack(spacing: 12) {
                            categoryLink(.vehicle) {
                                VehicleWidget(summary: summary(for: .vehicle))
                            }

                            HStack(spacing: 13) {
                                categoryLink(.pet) {
                                    SmallCategoryWidget(summary: summary(for: .pet))
                                }
                                categoryLink(.homeMaintenance) {
                                    SmallCategoryWidget(summary: summary(for: .homeMaintenance))
                                }
                            }

                            HStack(spacing: 13) {
                                categoryLink(.document) {
                                    SmallCategoryWidget(summary: summary(for: .document))
                                }
                                categoryLink(.other) {
                                    SmallCategoryWidget(summary: summary(for: .other))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 16) // rezerva pro vyvýšené plusko (bar řeší safeAreaInset)
                }
            }
            .navigationDestination(for: Category.self) { category in
                CategoryDetailView(category: category)
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
        .buttonStyle(.plain)
    }
}

// MARK: - GreetingCard

struct GreetingCard: View {
    let totalCount: Int
    let soonCount: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(Color.brandAccent)
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 36, height: 36)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Vítejte zpět")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.brandTextPrimary)
                        Text("Přehled vašich termínů")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                }

                HStack(spacing: 8) {
                    StatTile(label: "Sledováno", value: "\(totalCount)")
                    StatTile(label: "Brzy", value: "\(soonCount)")
                }
            }

            Spacer(minLength: 0)

            Image("IllustrationPerson")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 96)
                .accessibilityHidden(true)
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
        .frame(maxWidth: .infinity, alignment: .leading)
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
