//
//  OnboardingShowcase.swift
//  Kontrolka
//
//  Nativní rekonstrukce Figma Motion z 2. kroku onboardingu:
//  "camera zoom" do dashboardu → odkrytí detailu Domácnost se staggered nájezdem.
//  Časy/easing přebrány z Figma motion dat (ease-out-expo 0.16,1,0.3,1).
//  Přehraje se jednou při zobrazení (ne boomerang). Detail je lehká atrapa.
//

import SwiftUI

struct OnboardingShowcase: View {
    @State private var run = false

    var body: some View {
        ZStack {
            // Vrstva 1: dashboard — kamera do něj najede a rozostří ho
            dashboard
                .scaleEffect(run ? 2.1 : 1.0, anchor: UnitPoint(x: 0.75, y: 0.53))
                .blur(radius: run ? 6 : 0)
                .animation(.easeInOut(duration: 2.8), value: run)

            // Vrstva 2: detail Domácnost — odkryje se přes rozostřený dashboard
            detail
        }
        .clipped()
        .onAppear {
            run = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                run = true
            }
        }
    }

    // MARK: - Dashboard (reużívá reálné widgety)

    private var dashboard: some View {
        VStack(spacing: 12) {
            VehicleWidget(summary: sample(.vehicle, count: 4, title: "Dálniční známka", days: 5))
            HStack(spacing: 13) {
                SmallCategoryWidget(summary: sample(.pet, count: 1, title: "Veterina", days: 18))
                SmallCategoryWidget(summary: sample(.homeMaintenance, count: 1, title: "Kotel", days: 18))
            }
            HStack(spacing: 13) {
                SmallCategoryWidget(summary: sample(.document, count: 1, title: "Obč. průkaz", days: 18))
                SmallCategoryWidget(summary: sample(.other, count: 1, title: "Hasičák", days: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 150)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Detail Domácnost (atrapa pro animaci)

    private var detail: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 10) {
                Image(systemName: "house.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.brandAccent)
                Text("Rodinný dům")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
            }
            .modifier(Reveal(run: run, delay: 3.2))

            heroCard
                .modifier(Reveal(run: run, delay: 3.5))

            Text("TERMÍNY")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .modifier(Reveal(run: run, delay: 3.8))

            VStack(spacing: 12) {
                itemCard(title: "Kotel", date: "Revize za 18 dní", urgency: .warning)
                itemCard(title: "Komín", date: "12. 6. 2027", urgency: .normal)
                itemCard(title: "Střecha", date: "Pojistka - 3. 3. 2027", urgency: .normal)
            }
            .modifier(Reveal(run: run, delay: 4.1))

            addTermButton
                .modifier(Reveal(run: run, delay: 4.4))

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 110)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            BrandGradientBackground()
                .opacity(run ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(2.9), value: run)
                .ignoresSafeArea()
        )
        .opacity(run ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(1.0), value: run)
    }

    private var heroCard: some View {
        VStack(spacing: 4) {
            Image("IllustrationHouse")
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

            infoRow(label: "Postaveno", value: "1998", divider: true)
            infoRow(label: "Přidáno do appky", value: "2. 1. 2024", divider: false)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }

    private func infoRow(label: String, value: String, divider: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color.brandTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
        }
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            if divider {
                Rectangle().fill(Color.black.opacity(0.08)).frame(height: 1)
            }
        }
    }

    private func itemCard(title: String, date: String, urgency: Urgency) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(urgency.color)
                    .frame(width: 40, height: 40)
                Image(systemName: "house.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                Text("Domácnost")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.brandTextSecondary)
                Text(date)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(urgency.textColor)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }

    private var addTermButton: some View {
        Text("Přidat termín k domácnosti")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.brandAccent)
            .frame(maxWidth: .infinity)
            .frame(height: 51)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
            )
    }

    private func sample(_ category: Category, count: Int, title: String, days: Int) -> CategorySummary {
        let due = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let item = TrackedItem(title: title, category: category, dueDate: due)
        return CategorySummary(category: category, count: count, nearest: item)
    }
}

// MARK: - Staggered nájezd prvku (posun zdola + fade), easing z Figmy

private struct Reveal: ViewModifier {
    let run: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(run ? 1 : 0)
            .offset(y: run ? 0 : 18)
            .animation(.timingCurve(0.16, 1, 0.3, 1, duration: 0.8).delay(delay), value: run)
    }
}

#Preview {
    ZStack {
        BrandGradientBackground().ignoresSafeArea()
        OnboardingShowcase()
    }
}
