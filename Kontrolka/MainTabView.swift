//
//  MainTabView.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home
    case overview
    case profile
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .home
    @State private var showingAddOptions = false
    @State private var showingCamera = false
    @State private var showingAddSheet = false
    @State private var capturedImage: UIImage?
    @Namespace private var tabHighlightNS

    var body: some View {
        // Vlastní bottom bar: kapsle se 3 taby VYPLNÍ šířku, oddělené akční „+"
        // sedí na STEJNÉM řádku vpravo (HStack .center → shodný svislý střed)
        // s definovaným spacingem. Materiál baru i pluska zůstává nativní Liquid Glass.
        // safeAreaInset vyhradí obsahu místo, takže nic nemizí za barem.
        ZStack {
            currentTab
                .id(selectedTab)
                .transition(.opacity) // jemný cross-fade mezi taby
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomBar
        }
        .tint(Color.brandAccent) // Brand tint pro sheety i dialogy
        .confirmationDialog(
            "Přidat položku",
            isPresented: $showingAddOptions,
            titleVisibility: .visible
        ) {
            Button("Přidat ručně") {
                capturedImage = nil
                showingAddSheet = true
            }

            Button("Vyfotit doklad") {
                showingCamera = true
            }

            Button("Zrušit", role: .cancel) {}
        }
        .sheet(isPresented: $showingCamera) {
            CameraCaptureView { image in
                capturedImage = image
                showingAddSheet = true
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            if let image = capturedImage {
                // S přednahranou fotkou
                AddEditItemView(
                    modelContext: modelContext,
                    initialPhotoData: image.jpegData(compressionQuality: 0.8),
                    itemToEdit: nil
                )
            } else {
                // Bez fotky
                AddEditItemView(
                    modelContext: modelContext,
                    initialPhotoData: nil,
                    itemToEdit: nil
                )
            }
        }
    }

    @ViewBuilder
    private var currentTab: some View {
        switch selectedTab {
        case .home:
            DomuView()
        case .overview:
            ContentView()
        case .profile:
            ProfileView()
        }
    }

    // Řádek dole: kapsle s taby + oddělené „+" (stejný svislý střed díky HStack).
    private var bottomBar: some View {
        HStack(spacing: 12) {
            tabCapsule
            AddButton {
                showingAddOptions = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 0) // bar níž — jen safe area nad home indikátorem
    }

    // Kapsle se 3 taby, roztažená přes zbývající šířku vedle „+".
    // GlassEffectContainer zajišťuje nativní Liquid Glass „morph" highlightu
    // aktivního tabu mezi jednotlivými položkami.
    private var tabCapsule: some View {
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 0) {
                NavItem(tab: .home, icon: "house", label: "Domů", selection: $selectedTab, namespace: tabHighlightNS)
                NavItem(tab: .overview, icon: "list.bullet", label: "Přehled", selection: $selectedTab, namespace: tabHighlightNS)
                NavItem(tab: .profile, icon: "person", label: "Profil", selection: $selectedTab, namespace: tabHighlightNS)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 6)
        }
        .frame(maxWidth: .infinity)
        .modifier(GlassCapsuleSurface())
    }
}

// MARK: - Položka baru

private struct NavItem: View {
    let tab: AppTab
    let icon: String
    let label: String
    @Binding var selection: AppTab
    var namespace: Namespace.ID

    private var isSelected: Bool { selection == tab }

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.35)) {
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
            .padding(.vertical, 7)
            .background { highlight }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    // Nativní focus na aktivní tab: Liquid Glass highlight, který se přes
    // glassEffectID v GlassEffectContainer „přelije" (morph) mezi taby.
    @ViewBuilder
    private var highlight: some View {
        if isSelected {
            Capsule()
                .fill(Color.clear)
                .glassEffect(
                    .regular.tint(Color.brandAccent.opacity(0.28)).interactive(),
                    in: Capsule()
                )
                .glassEffectID("activeTabHighlight", in: namespace)
        }
    }
}

/// Pozadí kapsle baru — Liquid Glass na iOS 26+, jinak materiál/plná výplň.
private struct GlassCapsuleSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular, in: Capsule())
        } else {
            content
                .background(
                    reduceTransparency
                        ? AnyShapeStyle(Color.surfaceCardBase)
                        : AnyShapeStyle(.ultraThinMaterial),
                    in: Capsule()
                )
                .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
        }
    }
}

// Profil (dle Figma sekce Navigace / Profil)
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Brand gradient jako nejspodnější vrstva
                BrandGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        NavigationLink {
                            ProfileEditView()
                        } label: {
                            ProfileSummaryCard()
                        }
                        .buttonStyle(PressableCardStyle())

                        profileSection(title: "O APLIKACI") {
                            ProfileRow(icon: "info.circle", title: "Verze", trailing: "1.0.0")
                        }

                        profileSection(title: "SYSTÉM") {
                            Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                                ProfileRow(icon: "lock.shield", title: "Oprávnění", showsChevron: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Profil")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func profileSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
                .padding(.leading, 4)
            VStack(spacing: 8) {
                content()
            }
        }
    }
}

// Karta shrnutí profilu
struct ProfileSummaryCard: View {
    @AppStorage(ProfileStorage.nameKey) private var name = ""
    @AppStorage(ProfileStorage.birthDateKey) private var birthDateISO = ""

    private var subtitle: String {
        guard let date = Profile.birthDate(fromISO: birthDateISO) else {
            return "Klepni pro nastavení profilu"
        }
        let years = Profile.age(from: date)
        return "\(years) \(Profile.yearsWord(years)) · \(Profile.formattedBirthDate(date))"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.brandAccent)
                if name.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.white)
                } else {
                    Text(Profile.initial(from: name))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(name.isEmpty ? "Doplň profil" : name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }
}

// Řádek v profilu
struct ProfileRow: View {
    let icon: String
    let title: String
    var trailing: String? = nil
    var showsChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.brandAccent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(Color.brandTextPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.brandTextSecondary)
            }
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: TrackedItem.self, inMemory: true)
}
