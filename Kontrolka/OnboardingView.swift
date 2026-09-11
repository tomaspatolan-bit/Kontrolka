//
//  OnboardingView.swift
//  Kontrolka
//
//  Onboarding dle Figma sekce Onboarding: Uvítání → Hodnota/Notifikace → Profil.
//  Motion (Camera Zoom na 2. kroku) záměrně neimplementován — statický náhled.
//  Profil se ukládá do @AppStorage; napojení do GreetingCard/Profilu zatím ne.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("profileName") private var profileName = ""
    @AppStorage("profileBirthDate") private var profileBirthDate = ""

    @State private var step = 0
    @State private var name = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            switch step {
            case 0: welcomeStep
            case 1: valueStep
            default: profileStep
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    // MARK: - 1. Uvítání

    private var welcomeStep: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("AppMark")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .accessibilityHidden(true)

            Text("Vítej v Kontrolce")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.brandTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 28)

            Text("Appka, co tě upozorní dřív, než uvidíš tu skutečnou kontrolku.")
                .font(.system(size: 16))
                .foregroundStyle(Color.brandTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 32)

            Spacer()

            OnboardingPrimaryButton(title: "Další") {
                step = 1
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 2. Hodnota / Notifikace

    private var valueStep: some View {
        ZStack(alignment: .bottom) {
            // Nativní rekonstrukce Figma Motion (zoom do dashboardu → detail)
            OnboardingShowcase()
                .allowsHitTesting(false)

            // Nadpis nahoře se scrimem pro čitelnost
            VStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Všechno na jednom místě")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.brandTextPrimary)
                    Text("Auto, dům, mazlíček i doklady — Kontrolka hlídá termíny u všeho, co vlastníš.")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 24)
                .background(
                    LinearGradient(
                        colors: [Color.gradientEdge, Color.gradientEdge.opacity(0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                )
                Spacer()
            }

            OnboardingPrimaryButton(title: "Pokračovat") {
                requestNotificationsAndAdvance()
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 3. Profil

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("A ještě něco o tobě")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.brandTextPrimary)
                .padding(.top, 100)

            Text("Datum narození appce třeba pomůže spočítat, kdy přesně ti vyprší občanka.")
                .font(.system(size: 16))
                .foregroundStyle(Color.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            inputField(label: "Jméno") {
                TextField("Zadej jméno", text: $name)
                    .textInputAutocapitalization(.words)
            }
            .padding(.top, 24)

            inputField(label: "Datum narození") {
                DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 16)

            Spacer()

            OnboardingPrimaryButton(title: "Pokračovat") {
                finish()
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Pomocné

    private func inputField<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.brandTextSecondary)
            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.surfaceCardBase)
                )
        }
    }

    private func requestNotificationsAndAdvance() {
        Task {
            _ = await NotificationManager.shared.requestAuthorization()
            withAnimation(.easeInOut(duration: 0.3)) { step = 2 }
        }
    }

    private func finish() {
        profileName = name
        profileBirthDate = ISO8601DateFormatter().string(from: birthDate)
        withAnimation { hasCompletedOnboarding = true }
    }
}

// MARK: - Primární tlačítko onboardingu

struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.brandAccent)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    OnboardingView()
}
