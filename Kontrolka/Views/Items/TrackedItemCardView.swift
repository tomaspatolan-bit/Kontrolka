//
//  TrackedItemCardView.swift
//  Kontrolka
//
//  Karta pro položku v seznamu — nahrazuje původní řádek s barevnou tečkou.
//  Ikona = kategorie, barva pozadí ikony = naléhavost (urgency).
//

import SwiftUI

extension Category {
    /// SF Symbol odpovídající typu sledované položky.
    var iconName: String {
        switch self {
        case .vehicle: return "car.fill"
        case .insurance: return "shield.fill"
        case .homeMaintenance: return "wrench.and.screwdriver.fill"
        case .pet: return "pawprint.fill"
        case .warranty: return "checkmark.seal.fill"
        case .document: return "person.text.rectangle.fill"
        case .other: return "tray.fill"
        }
    }
}

struct TrackedItemCardView: View {
    let item: TrackedItem
    @Environment(\.colorScheme) private var colorScheme

    private var urgencyColor: Color { item.urgency.color }
    private var urgencyTextColor: Color { item.urgency.textColor }

    var body: some View {
        HStack(spacing: 14) {
            // Ikona v kolečku s glass efektem (iOS 26+) nebo plnou barvou (iOS 17-25)
            iconCircle
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(1)

                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(item.dueDateFormatted)
                    .font(.subheadline.weight(.semibold)) // Změněno z .medium na .semibold
                    .foregroundStyle(urgencyTextColor) // Použita textColor místo color
            }

            Spacer(minLength: 8)

            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .strokeBorder(.white.opacity(0.6), lineWidth: 1)
                    )
            }
            
            // Vlastní chevron v brand sekundární barvě
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        // Dvouvrstvý stín pro nadlehčení karty
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.10 : 0.05),
            radius: 6,
            y: 2
        )
        .shadow(
            color: .black.opacity(colorScheme == .dark ? 0.06 : 0.03),
            radius: 1,
            y: 1
        )
    }
    
    // MARK: - Ikona s glass efektem
    @ViewBuilder
    private var iconCircle: some View {
        if #available(iOS 26, *) {
            // iOS 26+: Nativní Liquid Glass s barevným tintem
            ZStack {
                Color.clear
                    .frame(width: 44, height: 44)
                    .glassEffect(.regular.tint(urgencyColor), in: Circle())
                
                Image(systemName: item.category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        } else {
            // iOS 17-25: Fallback na plnou barevnou výplň
            ZStack {
                Circle()
                    .fill(urgencyColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: item.category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(urgencyColor)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        TrackedItemCardView(
            item: TrackedItem(
                title: "STK - Škoda Octavia",
                category: .vehicle,
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!
            )
        )
        
        TrackedItemCardView(
            item: TrackedItem(
                title: "Povinné ručení",
                category: .insurance,
                dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date())!
            )
        )
        
        TrackedItemCardView(
            item: TrackedItem(
                title: "Revize komína",
                category: .homeMaintenance,
                dueDate: Calendar.current.date(byAdding: .day, value: 45, to: Date())!,
                photoData: UIImage(systemName: "wrench.and.screwdriver.fill")?.pngData()
            )
        )
    }
    .padding()
}
