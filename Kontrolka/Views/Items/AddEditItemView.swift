//
//  AddEditItemView.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//
//  Přidání i editace. U asset kategorií (Vozidlo/Domácnost/Mazlíček) je přidání
//  v režimu „věc + víc termínů": název věci + multi-chip termínů, každý s vlastním
//  datem → vytvoří TrackedThing + sadu položek. Ploché kategorie a editace jedné
//  položky používají klasický formulář (název, datum, podkategorie, poznámka, foto).
//

import SwiftUI
import SwiftData
import PhotosUI

/// Rozpracovaný termín v add flow věci (název + datum).
private struct DeadlineDraft: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var date: Date
}

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let itemToEdit: TrackedItem?
    /// Volitelný callback po úspěšném uložení. Když je nastaven, řízení převezme
    /// volající (např. onboarding dokončí flow) místo výchozího `dismiss()`.
    let onSaved: (() -> Void)?
    /// Když je zadané, přidáváme termíny k této existující věci (ne novou věc).
    let existingThing: TrackedThing?

    @State private var title: String
    @State private var category: Category
    @State private var subcategory: String
    @State private var dueDate: Date
    @State private var note: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoPreview = false

    // Asset add flow (věc + víc termínů)
    @State private var thingName: String = ""
    @State private var deadlines: [DeadlineDraft] = []
    @State private var customDeadline: String = ""

    init(modelContext: ModelContext, initialPhotoData: Data? = nil, initialCategory: Category? = nil, itemToEdit: TrackedItem? = nil, existingThing: TrackedThing? = nil, onSaved: (() -> Void)? = nil) {
        self.modelContext = modelContext
        self.itemToEdit = itemToEdit
        self.existingThing = existingThing
        self.onSaved = onSaved

        _title = State(initialValue: itemToEdit?.title ?? "")
        _category = State(initialValue: itemToEdit?.category ?? existingThing?.category ?? initialCategory ?? .vehicle)
        _subcategory = State(initialValue: itemToEdit?.subcategory ?? "")
        _dueDate = State(initialValue: itemToEdit?.dueDate ?? Self.defaultDate)
        _note = State(initialValue: itemToEdit?.note ?? "")

        // Pokud je initialPhotoData, použij ji; jinak použij photoData z itemToEdit
        if let initialPhotoData {
            _photoData = State(initialValue: initialPhotoData)
        } else {
            _photoData = State(initialValue: itemToEdit?.photoData)
        }
    }

    private static var defaultDate: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }

    /// Nová věc (asset kategorie, bez existující věci) = režim „věc + víc termínů".
    private var isNewThing: Bool {
        itemToEdit == nil && existingThing == nil && category.usesThings
    }
    /// Přidání termínů k existující věci.
    private var isAddToThing: Bool {
        itemToEdit == nil && existingThing != nil
    }
    /// Oba režimy používají multi-termínový builder.
    private var usesDeadlineBuilder: Bool { isNewThing || isAddToThing }

    private var canSave: Bool {
        if isAddToThing {
            return !deadlines.isEmpty
        } else if isNewThing {
            return !thingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !deadlines.isEmpty
        } else {
            return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var body: some View {
        ZStack {
            // Pozadí Gradient/Edge (světlá broskvová)
            Color.gradientEdge
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if usesDeadlineBuilder {
                            assetForm
                        } else {
                            flatForm
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    self.photoData = data
                }
            }
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let photoData, let uiImage = UIImage(data: photoData) {
                PhotoPreviewView(image: uiImage)
            }
        }
    }

    // MARK: - Header

    private var headerTitle: String {
        if itemToEdit != nil { return "Upravit položku" }
        if existingThing != nil { return "Nový termín" }
        return category.usesThings ? "Nová věc" : "Nová položka"
    }

    private var header: some View {
        ZStack {
            Text(headerTitle)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)

            HStack {
                pillButton("Zrušit", textColor: Color.brandTextPrimary) {
                    dismiss()
                }
                Spacer()
                pillButton("Uložit", textColor: canSave ? Color.brandAccent : Color.brandTextSecondary) {
                    saveItem()
                }
                .disabled(!canSave)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 16)
    }

    private func pillButton(_ label: String, textColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(textColor)
                .padding(.horizontal, 18)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.surfaceCardBase))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Klasický formulář (ploché kategorie + editace)

    @ViewBuilder
    private var flatForm: some View {
        TextField("Název", text: $title)
            .font(.system(size: 17))
            .padding(.vertical, 16)
            .accessibilityLabel("Název položky")
        rowDivider

        categoryRow
        rowDivider

        // Datum vypršení
        HStack {
            Text("Datum vypršení")
                .font(.system(size: 17))
                .foregroundStyle(Color.brandTextPrimary)
            Spacer()
            DatePicker("", selection: $dueDate, displayedComponents: .date)
                .labelsHidden()
                .tint(Color.brandAccent)
                .accessibilityLabel("Datum vypršení")
        }
        .padding(.vertical, 12)

        // Podkategorie
        sectionLabel("Podkategorie (volitelné)")
        TextField("Např. STK, pneu, rozvody…", text: $subcategory)
            .font(.system(size: 17))
            .padding(.bottom, 8)
            .accessibilityLabel("Podkategorie")
        subcategoryChips

        // Poznámka
        sectionLabel("Poznámka (volitelné)")
        TextField("Poznámka", text: $note, axis: .vertical)
            .font(.system(size: 17))
            .lineLimit(3...6)
            .padding(.bottom, 8)
            .accessibilityLabel("Poznámka")

        // Fotka
        sectionLabel("Fotka (volitelné)")
        photoSection
    }

    // MARK: - Asset formulář (věc + víc termínů)

    @ViewBuilder
    private var assetForm: some View {
        if isNewThing {
            TextField("Název (např. Škoda Octavia)", text: $thingName)
                .font(.system(size: 17))
                .padding(.vertical, 16)
                .accessibilityLabel("Název věci")
            rowDivider

            categoryRow
            rowDivider
        } else if let existingThing {
            HStack {
                Text(existingThing.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                Spacer()
                Text(existingThing.category.widgetTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.brandTextSecondary)
            }
            .padding(.vertical, 16)
            rowDivider
        }

        sectionLabel("Termíny")
        Text("Vyber, co u této věci hlídat. Ke každému nastav datum.")
            .font(.system(size: 13))
            .foregroundStyle(Color.brandTextSecondary)
            .padding(.bottom, 10)

        deadlineChips

        // Vlastní termín
        HStack(spacing: 10) {
            TextField("Vlastní termín", text: $customDeadline)
                .font(.system(size: 16))
                .accessibilityLabel("Vlastní termín")
            Button {
                addCustomDeadline()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(customDeadlineTrimmed == nil ? Color.brandTextSecondary : Color.brandAccent)
            }
            .buttonStyle(.plain)
            .disabled(customDeadlineTrimmed == nil)
        }
        .padding(.top, 6)
        .padding(.bottom, 4)

        // Vybrané termíny s datepickerem
        ForEach($deadlines) { $deadline in
            rowDivider
            HStack(spacing: 8) {
                Text(deadline.name)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                DatePicker("", selection: $deadline.date, displayedComponents: .date)
                    .labelsHidden()
                    .tint(Color.brandAccent)
                Button {
                    removeDeadline(deadline)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Odebrat termín \(deadline.name)")
            }
            .padding(.vertical, 12)
        }
    }

    private var categoryRow: some View {
        HStack {
            Text("Kategorie")
                .font(.system(size: 17))
                .foregroundStyle(Color.brandTextPrimary)
            Spacer()
            Picker("", selection: $category) {
                ForEach(Category.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.brandTextPrimary)
            .accessibilityLabel("Kategorie")
        }
        .padding(.vertical, 12)
    }

    // Chips termínů (multi-select) pro asset add flow.
    @ViewBuilder
    private var deadlineChips: some View {
        if !category.subcategorySuggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(category.subcategorySuggestions, id: \.self) { suggestion in
                        let selected = deadlines.contains { $0.name == suggestion }
                        Button {
                            toggleDeadline(suggestion)
                        } label: {
                            Text(suggestion)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selected ? Color.white : Color.brandAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(selected ? Color.brandAccent : Color.brandAccent.opacity(0.12))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Termín \(suggestion)")
                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // Chips s návrhy podkategorií (single-select) pro plochý formulář.
    @ViewBuilder
    private var subcategoryChips: some View {
        if !category.subcategorySuggestions.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(category.subcategorySuggestions, id: \.self) { suggestion in
                        let selected = subcategory == suggestion
                        Button {
                            subcategory = selected ? "" : suggestion
                        } label: {
                            Text(suggestion)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selected ? Color.white : Color.brandAccent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(selected ? Color.brandAccent : Color.brandAccent.opacity(0.12))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Podkategorie \(suggestion)")
                        .accessibilityAddTraits(selected ? [.isSelected] : [])
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Deadline helpers

    private var customDeadlineTrimmed: String? {
        let trimmed = customDeadline.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func toggleDeadline(_ name: String) {
        if let idx = deadlines.firstIndex(where: { $0.name == name }) {
            deadlines.remove(at: idx)
        } else {
            deadlines.append(DeadlineDraft(name: name, date: Self.defaultDate))
        }
    }

    private func addCustomDeadline() {
        guard let name = customDeadlineTrimmed else { return }
        if !deadlines.contains(where: { $0.name == name }) {
            deadlines.append(DeadlineDraft(name: name, date: Self.defaultDate))
        }
        customDeadline = ""
    }

    private func removeDeadline(_ deadline: DeadlineDraft) {
        deadlines.removeAll { $0.id == deadline.id }
    }

    private var trimmedSubcategory: String? {
        let trimmed = subcategory.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.brandTextPrimary)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.brandTextSecondary.opacity(0.18))
            .frame(height: 1)
    }

    @ViewBuilder
    private var photoSection: some View {
        if let photoData, let uiImage = UIImage(data: photoData) {
            VStack(alignment: .leading, spacing: 12) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .onTapGesture { showingPhotoPreview = true }
                    .accessibilityLabel("Fotka dokladu")

                Button(role: .destructive) {
                    withAnimation {
                        self.photoData = nil
                        self.selectedPhotoItem = nil
                    }
                } label: {
                    Label("Odstranit fotku", systemImage: "trash")
                        .font(.system(size: 15))
                }
            }
        } else {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label("Přidat fotku dokladu", systemImage: "photo")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.brandAccent)
            }
        }
    }

    private func saveItem() {
        if let itemToEdit {
            // Úprava existující položky
            itemToEdit.title = title
            itemToEdit.category = category
            itemToEdit.subcategory = trimmedSubcategory
            itemToEdit.dueDate = dueDate
            itemToEdit.note = note.isEmpty ? nil : note
            itemToEdit.photoData = photoData
            itemToEdit.updatedAt = Date()

            Task {
                await NotificationManager.shared.scheduleNotifications(for: itemToEdit)
            }
        } else if let existingThing {
            // Přidání termínů k existující věci
            for deadline in deadlines {
                let item = TrackedItem(
                    title: deadline.name,
                    category: existingThing.category,
                    dueDate: deadline.date,
                    thing: existingThing
                )
                modelContext.insert(item)
                Task {
                    await NotificationManager.shared.scheduleNotifications(for: item)
                }
            }
        } else if category.usesThings {
            // Nová věc + sada termínů (každý chip = vlastní položka pod věcí)
            let thing = TrackedThing(
                name: thingName.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category
            )
            modelContext.insert(thing)

            for deadline in deadlines {
                let item = TrackedItem(
                    title: deadline.name,
                    category: category,
                    dueDate: deadline.date,
                    thing: thing
                )
                modelContext.insert(item)
                Task {
                    await NotificationManager.shared.scheduleNotifications(for: item)
                }
            }
        } else {
            // Nová plochá položka
            let newItem = TrackedItem(
                title: title,
                category: category,
                subcategory: trimmedSubcategory,
                dueDate: dueDate,
                note: note.isEmpty ? nil : note,
                photoData: photoData
            )
            modelContext.insert(newItem)

            Task {
                await NotificationManager.shared.scheduleNotifications(for: newItem)
            }
        }

        // Když volající předal onSaved (onboarding), převezme řízení; jinak zavřeme sheet.
        if let onSaved {
            onSaved()
        } else {
            dismiss()
        }
    }
}

struct PhotoPreviewView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage

    var body: some View {
        NavigationStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .navigationTitle("Fotka dokladu")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Zavřít") {
                            dismiss()
                        }
                    }
                }
        }
    }
}

#Preview {
    AddEditItemView(
        modelContext: ModelContext(try! ModelContainer(for: TrackedItem.self)),
        initialPhotoData: nil,
        itemToEdit: nil
    )
}
