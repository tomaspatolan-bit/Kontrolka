//
//  OnboardingView.swift
//  Kontrolka
//
//  Onboarding: Uvítání → Hodnota/Notifikace → Profil → První položka.
//  V posledním kroku si uživatel přidá první sledovanou věc (nebo přeskočí),
//  aby přistál rovnou na plném dashboardu. Profil se ukládá do @AppStorage.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var step = 0
    @State private var name = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    @State private var addCategory: Category?

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            switch step {
            case 0: welcomeStep
            case 1: valueStep
            case 2: profileStep
            default: addFirstItemStep
            }
        }
        .animation(.easeInOut(duration: 0.3), value: step)
        .sheet(item: $addCategory) { category in
            // Po uložení dokončíme onboarding → uživatel přistane na plném dashboardu.
            AddEditItemView(modelContext: modelContext, initialCategory: category, onSaved: { finish() })
        }
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
                Haptics.impact(.light)
                step = 1
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - 2. Hodnota / Notifikace

    private var valueStep: some View {
        ZStack {
            // Výřez/okno s animovaným obsahem (zoom do dashboardu → detail),
            // rámovaný horní a dolní gradientovou vrstvou.
            OnboardingShowcase()
                .allowsHitTesting(false)

            // Horní vrstva: gradient + nadpis
            VStack(spacing: 0) {
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
                .padding(.bottom, 65)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: .gradientEdge, location: 0),
                            .init(color: .gradientEdge, location: 0.82),
                            .init(color: .gradientEdge.opacity(0), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                )

                Spacer(minLength: 0)
            }

            // Dolní vrstva: gradient + tlačítko
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                OnboardingPrimaryButton(title: "Pokračovat") {
                    requestNotificationsAndAdvance()
                }
                .padding(.horizontal, 28)
                .padding(.top, 55)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        stops: [
                            .init(color: .gradientEdge.opacity(0), location: 0),
                            .init(color: .gradientEdge, location: 0.18),
                            .init(color: .gradientEdge, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
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
                Haptics.impact(.light)
                withAnimation(.easeInOut(duration: 0.3)) { step = 3 }
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
    }

    // MARK: - 4. První položka

    private var addFirstItemStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Přidej první věc")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.brandTextPrimary)
                .padding(.top, 90)

            Text("Vyber, co chceš hlídat jako první. Zbytek klidně doplníš později.")
                .font(.system(size: 16))
                .foregroundStyle(Color.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            ScrollView(showsIndicators: false) {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(onboardingCategories, id: \.self) { category in
                        categoryTile(category)
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 12)
            }

            Button("Zatím přeskočit") {
                finish()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(Color.brandTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 28)
    }

    // Kategorie s ilustracemi nabízené v onboardingu (mají vlastní ilustraci)
    private var onboardingCategories: [Category] {
        [.vehicle, .homeMaintenance, .pet, .document, .other]
    }

    private func categoryTile(_ category: Category) -> some View {
        Button {
            Haptics.impact(.light)
            addCategory = category
        } label: {
            VStack(spacing: 10) {
                categoryIllustration(category)
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true)
                Text(category.widgetTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.surfaceCardBase)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Přidat kategorii \(category.widgetTitle)")
    }

    @ViewBuilder
    private func categoryIllustration(_ category: Category) -> some View {
        if let name = category.illustrationName {
            Image(name)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: category.iconName)
                .font(.system(size: 36))
                .foregroundStyle(Color.brandAccent)
        }
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
        let person = primaryPerson()
        person.name = name
        person.birthDateISO = Profile.iso(from: birthDate)
        try? modelContext.save()
        Haptics.success()
        withAnimation { hasCompletedOnboarding = true }
    }

    private func primaryPerson() -> Person {
        if let existing = (try? modelContext.fetch(FetchDescriptor<Person>()))?.first(where: { $0.isPrimary }) {
            return existing
        }
        let created = Person(isPrimary: true)
        modelContext.insert(created)
        return created
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
        .modelContainer(for: TrackedItem.self, inMemory: true)
}
