//
//  AddEditItemView.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddEditItemView: View {
    @Environment(\.dismiss) private var dismiss
    let modelContext: ModelContext
    let itemToEdit: TrackedItem?
    
    @State private var title: String
    @State private var category: Category
    @State private var dueDate: Date
    @State private var note: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var showingPhotoPreview = false
    
    init(modelContext: ModelContext, initialPhotoData: Data? = nil, initialCategory: Category? = nil, itemToEdit: TrackedItem? = nil) {
        self.modelContext = modelContext
        self.itemToEdit = itemToEdit

        _title = State(initialValue: itemToEdit?.title ?? "")
        _category = State(initialValue: itemToEdit?.category ?? initialCategory ?? .vehicle)
        _dueDate = State(initialValue: itemToEdit?.dueDate ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date())
        _note = State(initialValue: itemToEdit?.note ?? "")
        
        // Pokud je initialPhotoData, použij ji; jinak použij photoData z itemToEdit
        if let initialPhotoData {
            _photoData = State(initialValue: initialPhotoData)
        } else {
            _photoData = State(initialValue: itemToEdit?.photoData)
        }
    }
    
    var body: some View {
        ZStack {
            // Bílý list s jemným broskvovým přechodem nahoře (dle Figmy)
            LinearGradient(
                stops: [
                    .init(color: .gradientEdge, location: 0),
                    .init(color: Color(.systemBackground), location: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Název
                        TextField("Název", text: $title)
                            .font(.system(size: 17))
                            .padding(.vertical, 16)
                            .accessibilityLabel("Název položky")
                        rowDivider

                        // Kategorie
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

    private var header: some View {
        ZStack {
            Text(itemToEdit == nil ? "Nová položka" : "Upravit položku")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)

            HStack {
                pillButton("Zrušit", textColor: Color.brandTextPrimary) {
                    dismiss()
                }
                Spacer()
                pillButton("Uložit", textColor: title.isEmpty ? Color.brandTextSecondary : Color.brandAccent) {
                    saveItem()
                }
                .disabled(title.isEmpty)
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
            itemToEdit.dueDate = dueDate
            itemToEdit.note = note.isEmpty ? nil : note
            itemToEdit.photoData = photoData
            itemToEdit.updatedAt = Date()
            
            Task {
                await NotificationManager.shared.scheduleNotifications(for: itemToEdit)
            }
        } else {
            // Vytvoření nové položky
            let newItem = TrackedItem(
                title: title,
                category: category,
                dueDate: dueDate,
                note: note.isEmpty ? nil : note,
                photoData: photoData
            )
            modelContext.insert(newItem)
            
            Task {
                await NotificationManager.shared.scheduleNotifications(for: newItem)
            }
        }
        
        dismiss()
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
