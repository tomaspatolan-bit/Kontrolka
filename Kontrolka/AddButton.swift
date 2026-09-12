//
//  AddButton.swift
//  Kontrolka
//
//  Oddělené akční "+" tlačítko ukotvené vpravo dole vedle nativního TabView baru.
//  SwiftUI nemá tab-roli pro akci (jediný oddělený slot je .search s lupou),
//  proto je "+" samostatná komponenta.
//  iOS 26+: Liquid Glass s brand tintem. Starší: plná brand výplň.
//

import SwiftUI

struct AddButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            Haptics.impact()
            action()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .modifier(AddButtonSurface())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Přidat položku")
    }
}

/// Pozadí tlačítka — Liquid Glass na iOS 26+, jinak plná brand výplň.
private struct AddButtonSurface: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(
                    .regular.tint(Color.brandAccent).interactive(),
                    in: Circle()
                )
        } else {
            content
                .background(Circle().fill(Color.brandAccent))
                .shadow(color: .brandAccent.opacity(0.35), radius: 12, y: 6)
        }
    }
}

#Preview {
    ZStack {
        BrandGradientBackground().ignoresSafeArea()
        AddButton {}
    }
}
