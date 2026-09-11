//
//  ItemDetailView.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import SwiftData

struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let item: TrackedItem
    let modelContext: ModelContext
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingPhotoPreview = false
    @State private var showingCalendarSuccess = false
    @State private var showingCalendarError = false
    @State private var calendarErrorMessage = ""
    
    var body: some View {
        List {
            Section {
                DetailRow(label: "Název", value: item.title)
                DetailRow(label: "Kategorie", value: item.category.rawValue)
                DetailRow(label: "Datum vypršení", value: item.dueDate.formatted(date: .long, time: .omitted))
                
                HStack {
                    Text("Stav")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(item.urgency.color)
                            .frame(width: 10, height: 10)
                        Text(item.dueDateFormatted)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(item.urgency.textColor)
                    }
                }
            }
            
            if let note = item.note {
                Section {
                    Text(note)
                        .font(.body)
                } header: {
                    Text("Poznámka")
                }
            }
            
            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                Section {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .onTapGesture {
                            showingPhotoPreview = true
                        }
                        .accessibilityLabel("Fotka dokladu, klepněte pro zobrazení")
                } header: {
                    Text("Fotka dokladu")
                }
            }
            
            Section {
                Button {
                    Task {
                        await exportToCalendar()
                    }
                } label: {
                    Label("Přidat do kalendáře", systemImage: "calendar.badge.plus")
                }
                .accessibilityLabel("Přidat do kalendáře")
                
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Upravit", systemImage: "pencil")
                }
                .accessibilityLabel("Upravit položku")
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Smazat", systemImage: "trash")
                }
                .accessibilityLabel("Smazat položku")
            }
        }
        .scrollContentBackground(.hidden) // Prosvítání brand gradientu
        .navigationTitle("Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingEditSheet) {
            AddEditItemView(modelContext: modelContext, initialPhotoData: nil, itemToEdit: item)
        }
        .sheet(isPresented: $showingPhotoPreview) {
            if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
                PhotoPreviewView(image: uiImage)
            }
        }
        .alert("Smazat položku?", isPresented: $showingDeleteAlert) {
            Button("Zrušit", role: .cancel) {}
            Button("Smazat", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("Tuto akci nelze vrátit zpět.")
        }
        .alert("Přidáno do kalendáře", isPresented: $showingCalendarSuccess) {
            Button("OK") {}
        } message: {
            Text("Položka byla úspěšně přidána do systémového kalendáře.")
        }
        .alert("Chyba", isPresented: $showingCalendarError) {
            Button("OK") {}
        } message: {
            Text(calendarErrorMessage)
        }
    }
    
    private func deleteItem() {
        Task {
            await NotificationManager.shared.cancelNotifications(for: item)
        }
        modelContext.delete(item)
        dismiss()
    }
    
    private func exportToCalendar() async {
        let hasAccess = await CalendarManager.shared.requestAccess()
        
        guard hasAccess else {
            calendarErrorMessage = "Aplikace nemá oprávnění k přístupu do kalendáře. Povolte přístup v Nastavení."
            showingCalendarError = true
            return
        }
        
        do {
            try await CalendarManager.shared.exportToCalendar(item: item)
            showingCalendarSuccess = true
        } catch {
            calendarErrorMessage = "Nepodařilo se přidat položku do kalendáře."
            showingCalendarError = true
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

#Preview {
    NavigationStack {
        ItemDetailView(
            item: TrackedItem(
                title: "STK - Škoda Octavia",
                category: .vehicle,
                dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
                note: "Testovací poznámka"
            ),
            modelContext: ModelContext(try! ModelContainer(for: TrackedItem.self))
        )
    }
}
