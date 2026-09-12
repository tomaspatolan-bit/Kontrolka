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
    case add // oddělený trailing slot pro „+" (Tab(role: .search))
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .home
    @State private var showingAddOptions = false
    @State private var showingCamera = false
    @State private var showingAddSheet = false
    @State private var capturedImage: UIImage?

    // „+" je oddělené trailing tlačítko přes Tab(role: .search) — nativní TabView
    // ho vykreslí samostatně vpravo. Výběr .add ale NENÍ přepnutí obsahu: jen
    // otevře dialog a selection necháme na aktuálním tabu (žádný „prázdný" tab).
    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .add {
                    showingAddOptions = true
                } else {
                    selectedTab = newValue
                }
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            Tab("Domů", systemImage: "house", value: AppTab.home) {
                DomuView()
            }
            Tab("Přehled", systemImage: "list.bullet", value: AppTab.overview) {
                ContentView()
            }
            Tab("Profil", systemImage: "person", value: AppTab.profile) {
                ProfileView()
            }
            Tab("Přidat", systemImage: "plus", value: AppTab.add, role: .search) {
                // Obsah se reálně nezobrazí — výběr .add jen otevře dialog.
                Color.clear
            }
        }
        .tint(Color.brandAccent) // Brand tint pro bar, sheety i dialogy
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
