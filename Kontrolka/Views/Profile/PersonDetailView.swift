//
//  PersonDetailView.swift
//  Kontrolka
//
//  Osobní karta: avatar + jméno + seznam osobních dokladů s platností.
//  Otevírá se klepnutím na uvítací kartu na Domů.
//

import SwiftUI
import SwiftData

struct PersonDetailView: View {
    let person: Person
    let modelContext: ModelContext

    @State private var showingAdd = false

    private var documents: [TrackedItem] {
        person.documents.sorted { $0.dueDate < $1.dueDate }
    }

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    heroCard

                    Text("DOKLADY")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.brandTextPrimary)
                        .padding(.leading, 4)

                    if documents.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(documents) { item in
                                NavigationLink(value: item) {
                                    TrackedItemCardView(item: item)
                                }
                                .buttonStyle(PressableCardStyle())
                            }
                        }
                    }

                    addButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(person.name.isEmpty ? "Osobní karta" : person.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProfileEditView()
                } label: {
                    Image(systemName: "pencil")
                        .foregroundStyle(Color.brandAccent)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AddEditItemView(modelContext: modelContext, initialCategory: .document)
        }
    }

    // MARK: - Hero

    private var heroCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.brandAccent)
                if person.name.isEmpty {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                } else {
                    Text(Profile.initial(from: person.name))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.white)
                }
            }
            .frame(width: 72, height: 72)

            VStack(spacing: 4) {
                Text(person.name.isEmpty ? "Doplň profil" : person.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
        .shadow(color: .black.opacity(0.08), radius: 16, y: 8)
    }

    private var subtitle: String {
        let count = documents.count
        let docWord = count == 1 ? "doklad" : (count < 5 ? "doklady" : "dokladů")
        if let date = person.birthDate {
            let years = Profile.age(from: date)
            return "\(years) \(Profile.yearsWord(years)) · \(count) \(docWord)"
        }
        return "\(count) \(docWord)"
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("Zatím žádné doklady")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
            Text("Přidej doklad a jeho platnost tlačítkem níže.")
                .font(.system(size: 13))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }

    private var addButton: some View {
        Button {
            showingAdd = true
        } label: {
            Text("Přidat doklad")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.brandAccent)
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.brandAccent, style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
        }
        .buttonStyle(.plain)
    }
}
