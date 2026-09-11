//
//  MainTabView.swift
//  Kontrolka
//
//  Created by Tomáš PATOLÁN on 04.09.2026.
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case list
    case calendar
    case placeholder
    case settings
}

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: AppTab = .list
    @State private var showingAddOptions = false
    @State private var showingCamera = false
    @State private var showingAddSheet = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .list:
                    ContentView()
                case .calendar:
                    CalendarTabView()
                case .placeholder:
                    PlaceholderTabView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom tab bar
            CustomTabBar(
                selectedTab: $selectedTab,
                onAddTapped: {
                    showingAddOptions = true
                }
            )
        }
        .tint(Color.brandAccent) // Brand tint pro celou appku
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

// Placeholder pro Settings view
struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Brand gradient jako nejspodnější vrstva
                BrandGradientBackground()
                    .ignoresSafeArea()
                
                // List na vrchu
                List {
                    Section {
                        HStack {
                            Text("Verze")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("O aplikaci")
                    }
                    
                    Section {
                        Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                            HStack {
                                Label("Oprávnění", systemImage: "lock.shield")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Systém")
                    }
                }
                .scrollContentBackground(.hidden) // Prosvítání brand gradientu
            }
            .navigationTitle("Nastavení")
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// Kalendář tab s měsíční mřížkou
struct CalendarTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var items: [TrackedItem]
    
    @State private var currentMonth: Date = Date()
    @State private var selectedDayItems: [TrackedItem]? = nil
    @State private var showingDaySheet = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Brand gradient jako nejspodnější vrstva
                BrandGradientBackground()
                    .ignoresSafeArea()
                
                // VStack s obsahem na vrchu
                VStack(spacing: 0) {
                    // Měsíc a navigace
                    monthNavigationView
                    
                    // Dny v týdnu header
                    weekdayHeaderView
                    
                    // Kalendářní mřížka
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
                            ForEach(daysInMonth(), id: \.self) { day in
                                dayCell(for: day)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Kalendář")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingDaySheet) {
                if let dayItems = selectedDayItems, !dayItems.isEmpty {
                    DayItemsSheet(items: dayItems, modelContext: modelContext)
                }
            }
        }
    }
    
    // Navigace měsíců
    private var monthNavigationView: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2.weight(.semibold))
            
            Spacer()
            
            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.blue)
            }
        }
        .padding()
    }
    
    // Header s dny v týdnu
    private var weekdayHeaderView: some View {
        HStack(spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
    
    // Buňka pro den
    @ViewBuilder
    private func dayCell(for date: Date?) -> some View {
        if let date {
            let itemsForDay = items(for: date)
            let isToday = calendar.isDateInToday(date)
            let mostUrgentColor = mostUrgentColor(for: itemsForDay)
            
            Button {
                if !itemsForDay.isEmpty {
                    selectedDayItems = itemsForDay
                    showingDaySheet = true
                }
            } label: {
                VStack(spacing: 4) {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.body.weight(isToday ? .bold : .regular))
                        .foregroundStyle(isToday ? .white : .primary)
                    
                    if let dotColor = mostUrgentColor {
                        Circle()
                            .fill(dotColor)
                            .frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .fill(.clear)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isToday ? .blue : .clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(isToday ? .blue.opacity(0.5) : .clear, lineWidth: 2)
                )
            }
            .disabled(itemsForDay.isEmpty)
        } else {
            Color.clear
                .frame(height: 44)
        }
    }
    
    // Pomocné metody
    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
        else {
            return []
        }
        
        var days: [Date?] = []
        
        // Prázdné buňky na začátku (po -> ne)
        let emptyDays = (firstWeekday + 5) % 7 // Konverze z Ne=1 na Po=0
        days.append(contentsOf: Array(repeating: nil, count: emptyDays))
        
        // Dny v měsíci
        var currentDate = monthInterval.start
        while currentDate < monthInterval.end {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    private func items(for date: Date) -> [TrackedItem] {
        items.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
    }
    
    private func mostUrgentColor(for items: [TrackedItem]) -> Color? {
        guard !items.isEmpty else { return nil }
        
        // Pokud existuje alespoň jedna critical -> červená
        if items.contains(where: { $0.urgency == .critical }) {
            return .red
        }
        // Pokud existuje alespoň jedna warning -> oranžová
        if items.contains(where: { $0.urgency == .warning }) {
            return .orange
        }
        // Jinak zelená
        return .green
    }
    
    private func changeMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = newMonth
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "cs_CZ")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: currentMonth).capitalized
    }
    
    private var weekdaySymbols: [String] {
        var symbols = calendar.veryShortWeekdaySymbols
        // Rotuj aby začínalo pondělím
        let sunday = symbols.removeFirst()
        symbols.append(sunday)
        return symbols.map { $0.uppercased() }
    }
}

// Sheet se seznamem položek pro vybraný den
struct DayItemsSheet: View {
    let items: [TrackedItem]
    let modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        ItemDetailView(item: item, modelContext: modelContext)
                    } label: {
                        TrackedItemCardView(item: item)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden) // Prosvítání brand gradientu
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zavřít") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateString: String {
        guard let firstItem = items.first else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "cs_CZ")
        formatter.dateFormat = "d. MMMM yyyy"
        return formatter.string(from: firstItem.dueDate)
    }
}

// Placeholder tab (připraveno pro budoucí funkci)
struct PlaceholderTabView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Brand gradient jako nejspodnější vrstva
                BrandGradientBackground()
                    .ignoresSafeArea()
                
                // Content na vrchu
                ContentUnavailableView(
                    "Připravujeme",
                    systemImage: "sparkles",
                    description: Text("Tato funkce bude dostupná v příští verzi")
                )
            }
            .navigationTitle("Nové")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: TrackedItem.self, inMemory: true)
}
