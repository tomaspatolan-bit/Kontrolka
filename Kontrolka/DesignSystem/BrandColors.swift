//
//  BrandColors.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//
//  Barevná identita aplikace — tokeny pro light i dark mode.
//

import SwiftUI

extension Color {
    // MARK: - Brand Accent Colors
    
    /// Hlavní brand akcent — plus tlačítko, aktivní tab, odkazy, tint appky
    static var brandAccent: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#E08A63")
                : Self.color(from: "#C96F4A")
        })
    }
    
    /// Volitelný sekundární akcent (amber)
    static var brandAmber: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#F0B979")
                : Self.color(from: "#E8A659")
        })
    }
    
    // MARK: - Urgency Colors - Fill (ikony, tečky)
    
    /// Kritická naléhavost - výplň ikony/tečky
    static var urgencyCriticalFill: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#D9694F")
                : Self.color(from: "#C1503D")
        })
    }
    
    /// Varování - výplň ikony/tečky
    static var urgencyWarningFill: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#E8A15C")
                : Self.color(from: "#D98A3D")
        })
    }
    
    /// Normální stav - výplň ikony/tečky
    static var urgencyNormalFill: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#7FA377")
                : Self.color(from: "#6B8F63")
        })
    }
    
    // MARK: - Urgency Colors - Text
    
    /// Kritická naléhavost - text data
    static var urgencyCriticalText: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#E8927C")
                : Self.color(from: "#A63F2E")
        })
    }
    
    /// Varování - text data
    static var urgencyWarningText: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#F0B478")
                : Self.color(from: "#B06B1F")
        })
    }
    
    /// Normální stav - text data
    static var urgencyNormalText: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#9AC090")
                : Self.color(from: "#4F6B49")
        })
    }
    
    // MARK: - Brand Text Colors
    
    /// Primární text - nadpisy
    static var brandTextPrimary: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#F2E9DE")
                : Self.color(from: "#3A3128")
        })
    }
    
    /// Sekundární text - kategorie, popisky
    static var brandTextSecondary: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#B5A99B")
                : Self.color(from: "#8A7F76")
        })
    }
    
    // MARK: - Surface Tokens (Figma: Surface/CardBase)

    /// Pozadí karet a widgetů (světle béžová)
    static var surfaceCardBase: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? Self.color(from: "#2A2320") // prozatímní dark, dořeší se později
                : Self.color(from: "#F2EAE0")
        })
    }

    // MARK: - Gradient Tokens (Figma: Gradient/Edge, Gradient/Core)
    //  Dark mode se dořeší později — zatím jen light hodnoty.

    /// Světlý okraj brand gradientu (broskvová)
    static var gradientEdge: Color { Color(hex: "#F7E5CC") }

    /// Sytý střed brand gradientu (terakota)
    static var gradientCore: Color { Color(hex: "#D68C55") }

    // MARK: - Helper Method

    /// Konverze hex stringu (#RRGGBB) na UIColor
    private static func color(from hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    /// Vytvoří Color z hex stringu (#RRGGBB)
    init(hex: String) {
        let uiColor = Self.color(from: hex)
        self.init(uiColor: uiColor)
    }
}

// MARK: - Background Gradient

extension View {
    /// Aplikuje brand gradient pozadí na view
    func brandGradientBackground() -> some View {
        self.background(
            BrandGradientBackground()
                .ignoresSafeArea()
        )
    }
}

// MARK: - Brand Gradient Background View

struct BrandGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            gradient: colorScheme == .dark ? darkGradient : lightGradient,
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Light mode: Figma tokeny Gradient/Edge → Core (40 %) → Edge
    private var lightGradient: Gradient {
        Gradient(stops: [
            .init(color: .gradientEdge, location: 0.0),
            .init(color: .gradientCore, location: 0.4),
            .init(color: .gradientEdge, location: 1.0)
        ])
    }

    // Dark mode: prozatímní hodnoty, dořeší se později (viz CLAUDE.md)
    private var darkGradient: Gradient {
        Gradient(colors: [
            Color(hex: "#4A2545"), Color(hex: "#6B2F3D"),
            Color(hex: "#8B3A4A"), Color(hex: "#8F4A2E"), Color(hex: "#3A1F3D")
        ])
    }
}
