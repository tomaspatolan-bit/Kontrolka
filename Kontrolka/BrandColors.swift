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
        if #available(iOS 18, *) {
            // iOS 18+: Nativní MeshGradient
            linearGradientFallback
        } else {
            // iOS 17: Fallback na pětibodový LinearGradient
            linearGradientFallback
        }
    }
    
    // MARK: - iOS 18+ MeshGradient
    @available(iOS 18, *)
    private var meshGradientBackground: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0],   [0.5, 0],   [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1],   [0.5, 1],   [1, 1]
            ],
            colors: colorScheme == .dark ? darkMeshColors : lightMeshColors,
            smoothsColors: true
        )
    }
    
    // Light mode mesh colors (9 bodů)
    @available(iOS 18, *)
    private var lightMeshColors: [Color] {
        [
            Color(hex: "#FFD27A"), Color(hex: "#FF9F55"), Color(hex: "#FF7A6B"),
            Color(hex: "#FFB25E"), Color(hex: "#F2637F"), Color(hex: "#E85C9C"),
            Color(hex: "#E8873D"), Color(hex: "#C1503D"), Color(hex: "#8B4A8F")
        ]
    }
    
    // Dark mode mesh colors (9 bodů)
    @available(iOS 18, *)
    private var darkMeshColors: [Color] {
        [
            Color(hex: "#4A2545"), Color(hex: "#6B2F3D"), Color(hex: "#7A3A2E"),
            Color(hex: "#5C2A4F"), Color(hex: "#8B3A4A"), Color(hex: "#8F4A2E"),
            Color(hex: "#3A1F3D"), Color(hex: "#5C2A2E"), Color(hex: "#2E1A2E")
        ]
    }
    
    // MARK: - iOS 17 LinearGradient Fallback
    private var linearGradientFallback: some View {
        LinearGradient(
            colors: colorScheme == .dark ? darkLinearColors : lightLinearColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Light mode linear colors (5 bodů)
    private var lightLinearColors: [Color] {
        [
            Color(hex: "#FFD27A"), Color(hex: "#FF9F55"),
            Color(hex: "#F2637A"), Color(hex: "#E85C9C"), Color(hex: "#8B4A8F")
        ]
    }
    
    // Dark mode linear colors (5 bodů)
    private var darkLinearColors: [Color] {
        [
            Color(hex: "#4A2545"), Color(hex: "#6B2F3D"),
            Color(hex: "#8B3A4A"), Color(hex: "#8F4A2E"), Color(hex: "#3A1F3D")
        ]
    }
}
