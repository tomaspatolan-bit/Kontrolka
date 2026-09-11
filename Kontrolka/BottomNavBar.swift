//
//  BottomNavBar.swift
//  Kontrolka
//
//  Custom bottom navigace s prostředním "+" slotem. Layout je vlastní
//  (nativní TabView neumí zvětšený/objímaný střed), materiál zůstává
//  nativní Liquid Glass. Na iOS 26 se sklo baru a pluska přes
//  GlassEffectContainer slije = bar plusko "objímá".
//

import SwiftUI

struct BottomNavBar: View {
    @Binding var selection: AppTab
    let onAdd: () -> Void

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        barContent
            .padding(.horizontal, 24)
            .padding(.top, 30) // rezerva nad barem pro vyvýšené plusko
            .padding(.bottom, 6)
    }

    @ViewBuilder
    private var barContent: some View {
        // Bar i plusko jsou SAMOSTATNÉ sklo (žádný GlassEffectContainer),
        // aby tint pluska nevtékal do baru.
        ZStack {
            if #available(iOS 26, *) {
                itemsRow
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .glassEffect(.regular, in: Capsule())
            } else {
                itemsRow
                    .padding(.vertical, 10)
                    .padding(.horizontal, 18)
                    .background(
                        reduceTransparency
                            ? AnyShapeStyle(Color.surfaceCardBase)
                            : AnyShapeStyle(.ultraThinMaterial),
                        in: Capsule()
                    )
                    .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
            }

            AddButton(action: onAdd)
                .offset(y: -22) // vyvýšení nad bar
        }
    }

    private var itemsRow: some View {
        HStack(spacing: 0) {
            NavItem(tab: .home, icon: "house", label: "Domů", selection: $selection)
            NavItem(tab: .calendar, icon: "calendar", label: "Kalendář", selection: $selection)

            // Místo pro vyvýšené plusko
            Spacer().frame(width: 64)

            NavItem(tab: .overview, icon: "list.bullet", label: "Přehled", selection: $selection)
            NavItem(tab: .profile, icon: "person", label: "Profil", selection: $selection)
        }
    }
}

// MARK: - Položka baru

private struct NavItem: View {
    let tab: AppTab
    let icon: String
    let label: String
    @Binding var selection: AppTab

    private var isSelected: Bool { selection == tab }

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) {
                selection = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                    .symbolVariant(isSelected ? .fill : .none)
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.brandAccent : Color.brandTextSecondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#Preview {
    ZStack {
        BrandGradientBackground().ignoresSafeArea()
        VStack {
            Spacer()
            BottomNavBar(selection: .constant(.home)) {}
        }
    }
}
