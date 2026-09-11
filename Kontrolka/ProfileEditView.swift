//
//  ProfileEditView.swift
//  Kontrolka
//
//  Úprava profilu (jméno + datum narození), dle Figma „Profil-Edit".
//  Ukládá do @AppStorage přes ProfileStorage klíče.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(ProfileStorage.nameKey) private var storedName = ""
    @AppStorage(ProfileStorage.birthDateKey) private var storedBirthDateISO = ""

    @State private var name = ""
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()

    var body: some View {
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 24) {
                        avatar
                            .padding(.top, 12)

                        field(label: "Jméno") {
                            TextField("Zadej jméno", text: $name)
                                .textInputAutocapitalization(.words)
                        }

                        field(label: "Datum narození") {
                            DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }

                OnboardingPrimaryButton(title: "Uložit") {
                    save()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear(perform: loadFromStorage)
    }

    private var avatar: some View {
        ZStack {
            Circle().fill(Color.brandAccent)
            if name.trimmingCharacters(in: .whitespaces).isEmpty {
                Image(systemName: "person.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.white)
            } else {
                Text(Profile.initial(from: name))
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color.white)
            }
        }
        .frame(width: 72, height: 72)
    }

    private func field<Content: View>(
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

    private func loadFromStorage() {
        name = storedName
        if let date = Profile.birthDate(fromISO: storedBirthDateISO) {
            birthDate = date
        }
    }

    private func save() {
        storedName = name
        storedBirthDateISO = Profile.iso(from: birthDate)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProfileEditView()
    }
}
