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
    
    init(modelContext: ModelContext, initialPhotoData: Data? = nil, itemToEdit: TrackedItem? = nil) {
        self.modelContext = modelContext
        self.itemToEdit = itemToEdit
        
        _title = State(initialValue: itemToEdit?.title ?? "")
        _category = State(initialValue: itemToEdit?.category ?? .vehicle)
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
        NavigationStack {
            Form {
                Section {
                    TextField("Název", text: $title)
                        .accessibilityLabel("Název položky")
                    
                    Picker("Kategorie", selection: $category) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .accessibilityLabel("Kategorie")
                    
                    DatePicker("Datum vypršení", selection: $dueDate, displayedComponents: .date)
                        .accessibilityLabel("Datum vypršení")
                }
                
                Section {
                    TextField("Poznámka", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Poznámka")
                } header: {
                    Text("Poznámka (volitelné)")
                }
                
                Section {
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        VStack(spacing: 12) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture {
                                    showingPhotoPreview = true
                                }
                                .accessibilityLabel("Fotka dokladu")
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    self.photoData = nil
                                    self.selectedPhotoItem = nil
                                }
                            } label: {
                                Label("Odstranit fotku", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    } else {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Přidat fotku dokladu", systemImage: "photo")
                        }
                    }
                } header: {
                    Text("Fotka (volitelné)")
                }
            }
            .scrollContentBackground(.hidden) // Prosvítání brand gradientu
            .navigationTitle(itemToEdit == nil ? "Nová položka" : "Upravit položku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zrušit") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Uložit") {
                        saveItem()
                    }
                    .disabled(title.isEmpty)
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
