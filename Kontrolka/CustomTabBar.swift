//
//  CustomTabBar.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    let onAddTapped: () -> Void
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    
    var body: some View {
        HStack(spacing: 0) {
            // První dva taby (Domů, Kalendář)
            TabBarButton(
                tab: .home,
                selectedTab: $selectedTab,
                icon: "house",
                title: "Domů",
                reduceTransparency: reduceTransparency
            )

            TabBarButton(
                tab: .calendar,
                selectedTab: $selectedTab,
                icon: "calendar",
                title: "Kalendář",
                reduceTransparency: reduceTransparency
            )

            // Prostřední plusko - zarovnané doprostřed
            Spacer()
                .frame(width: 80) // Prostor pro vystouplé tlačítko

            // Druhé dva taby (Přehled, Profil)
            TabBarButton(
                tab: .overview,
                selectedTab: $selectedTab,
                icon: "list.bullet",
                title: "Přehled",
                reduceTransparency: reduceTransparency
            )

            TabBarButton(
                tab: .profile,
                selectedTab: $selectedTab,
                icon: "person",
                title: "Profil",
                reduceTransparency: reduceTransparency
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            ZStack {
                // Skleněný efekt pro bar
                Capsule()
                    .fill(reduceTransparency ? .regularMaterial : .ultraThinMaterial)
                
                if !reduceTransparency {
                    Capsule()
                        .fill(.background.opacity(0.5))
                }
            }
        )
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        .overlay(alignment: .top) {
            // Vystouplé plus tlačítko - zarovnané doprostřed
            Button(action: onAddTapped) {
                ZStack {
                    if reduceTransparency {
                        // Pevné pozadí pro accessibility
                        Circle()
                            .fill(Color.brandAccent.opacity(0.9))
                            .frame(width: 60, height: 60)
                    } else {
                        // Liquid glass efekt pro plus tlačítko
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.brandAccent, Color.brandAccent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 60)
                            .opacity(0.3)
                    }
                    
                    Image(systemName: "plus")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .shadow(color: .brandAccent.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .offset(y: -40) // Vystouplé nad bar
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}

struct TabBarButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab
    let icon: String
    let title: String
    let reduceTransparency: Bool
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected && !reduceTransparency {
                        // Liquid glass focus pro aktivní tab
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Circle()
                                    .fill(Color.brandAccent.opacity(0.15))
                                    .frame(width: 50, height: 50)
                            }
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: isSelected ? 24 : 22))
                        .symbolRenderingMode(.hierarchical)
                }
                .frame(height: 50)
                
                Text(title)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? Color.brandAccent : Color.secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(
            selectedTab: .constant(.calendar),
            onAddTapped: {}
        )
    }
}
