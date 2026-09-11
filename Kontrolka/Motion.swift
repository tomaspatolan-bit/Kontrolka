//
//  Motion.swift
//  Kontrolka
//
//  Sdílené mikroanimace a přechody. Vše nativní, bez závislostí.
//

import SwiftUI

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
