//
//  Motion.swift
//  Kontrolka
//
//  Sdílené mikroanimace a přechody. Vše nativní, bez závislostí.
//

import SwiftUI
import UIKit

/// Haptická odezva (nativní).
enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

/// Vstupní nájezd prvku (fade + posun zdola), řízený jedním boolem.
struct AppearReveal: ViewModifier {
    let isVisible: Bool
    var delay: Double = 0

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .animation(.timingCurve(0.16, 1, 0.3, 1, duration: 0.5).delay(delay), value: isVisible)
    }
}

extension View {
    func appearReveal(_ isVisible: Bool, delay: Double = 0) -> some View {
        modifier(AppearReveal(isVisible: isVisible, delay: delay))
    }
}

/// Tlačítkový styl s jemným „zmáčknutím" — mikrointerakce pro karty/widgety.
struct PressableCardStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

extension View {
    /// Zdroj zoom přechodu (iOS 18+). Na starších systémech se nic nemění.
    @ViewBuilder
    func zoomSource(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            self.matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }

    /// Cíl zoom přechodu (iOS 18+) — obrazovka „vyroste" ze zdroje.
    /// Na starších systémech zůstává standardní push.
    @ViewBuilder
    func zoomTransition(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            self.navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}
