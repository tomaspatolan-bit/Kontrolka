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
        ZStack {
            BrandGradientBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    heroCard
                    infoCard
                    photoCard
                    actions
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
        }
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
    
    // MARK: - Karty

    private var heroCard: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(item.urgency.color.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: item.category.iconName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(item.urgency.color)
            }

            VStack(spacing: 4) {
                Text(item.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .multilineTextAlignment(.center)
                Text(item.subcategory.map { "\(item.category.rawValue) · \($0)" } ?? item.category.rawValue)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.brandTextSecondary)
            }

            HStack(spacing: 6) {
                Circle()
                    .fill(item.urgency.color)
                    .frame(width: 8, height: 8)
                Text(item.dueDateFormatted)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(item.urgency.textColor)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Datum vypršení")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.brandTextSecondary)
                Spacer()
                Text(item.dueDate.formatted(date: .long, time: .omitted))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.brandTextPrimary)
            }
            .padding(.vertical, 14)

            if let note = item.note, !note.isEmpty {
                Rectangle()
                    .fill(Color.brandTextSecondary.opacity(0.15))
                    .frame(height: 1)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Poznámka")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.brandTextSecondary)
                    Text(note)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.brandTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 14)
            }
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.surfaceCardBase)
        )
    }

    @ViewBuilder
    private var photoCard: some View {
        if let photoData = item.photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onTapGesture { showingPhotoPreview = true }
                .accessibilityLabel("Fotka dokladu, klepněte pro zobrazení")
        }
    }

    private var actions: some View {
        VStack(spacing: 10) {
            actionButton("Přidat do kalendáře", icon: "calendar.badge.plus") {
                Task { await exportToCalendar() }
            }
            actionButton("Upravit", icon: "pencil") {
                showingEditSheet = true
            }
            actionButton("Smazat", icon: "trash", destructive: true) {
                showingDeleteAlert = true
            }
        }
    }

    private func actionButton(
        _ label: String,
        icon: String,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(destructive ? Color.urgencyCriticalText : Color.brandAccent)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.surfaceCardBase)
            )
        }
        .buttonStyle(PressableCardStyle())
        .accessibilityLabel(label)
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
