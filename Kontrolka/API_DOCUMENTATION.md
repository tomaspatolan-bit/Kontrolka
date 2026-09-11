# API Documentation

## 📚 Kontrolka MVP - Internal API Reference

Tato dokumentace popisuje hlavní komponenty a jejich použití.

---

## Models

### `TrackedItem`

SwiftData model reprezentující sledovanou položku.

```swift
@Model
final class TrackedItem {
    var id: UUID
    var title: String
    var category: Category
    var dueDate: Date
    var note: String?
    var photoData: Data?
    var customReminderDays: [Int]?
    var createdAt: Date
    var updatedAt: Date
    
    var reminderDays: [Int] { get }  // Computed property
    var urgency: Urgency { get }      // Extension
    var dueDateFormatted: String { get } // Extension
}
```

**Initializer:**
```swift
TrackedItem(
    id: UUID = UUID(),
    title: String,
    category: Category,
    dueDate: Date,
    note: String? = nil,
    photoData: Data? = nil,
    customReminderDays: [Int]? = nil,
    createdAt: Date = Date(),
    updatedAt: Date = Date()
)
```

**Properties:**
- `id` - Unikátní identifikátor
- `title` - Název položky (např. "STK - Škoda Octavia")
- `category` - Kategorie z enum `Category`
- `dueDate` - Datum vypršení
- `note` - Volitelná poznámka
- `photoData` - Volitelná fotka dokladu jako `Data`
- `customReminderDays` - Vlastní kadence notifikací (přepíše default)
- `createdAt` - Datum vytvoření
- `updatedAt` - Datum poslední úpravy
- `reminderDays` - Computed property: vrací `customReminderDays` nebo default podle kategorie
- `urgency` - Computed property: vrací `.critical`, `.warning`, nebo `.normal` podle zbývajících dní
- `dueDateFormatted` - Computed property: vrací formátovaný string ("za X dní", "vyprší zítra", atd.)

**Příklad použití:**
```swift
let item = TrackedItem(
    title: "STK - Škoda Octavia",
    category: .vehicle,
    dueDate: Calendar.current.date(byAdding: .day, value: 15, to: Date())!,
    note: "Objednat 2 týdny předem"
)

modelContext.insert(item)
```

---

### `Category`

Enum reprezentující kategorie položek.

```swift
enum Category: String, Codable, CaseIterable {
    case vehicle = "Vozidlo"
    case insurance = "Pojištění"
    case homeMaintenance = "Domácnost"
    case warranty = "Záruka"
    case document = "Doklad"
    case other = "Ostatní"
    
    var defaultReminderDays: [Int] { get }
}
```

**Cases:**
- `.vehicle` - Pro STK, dálniční známky, atd.
- `.insurance` - Pro pojistky (auto, nemovitost, zdravotní)
- `.homeMaintenance` - Pro revize (komín, kotel, elektro)
- `.warranty` - Pro záruky na spotřebiče
- `.document` - Pro platnost dokladů (OP, řidičák, pas)
- `.other` - Pro vše ostatní

**Default reminder days:**
- Kritické (.vehicle, .insurance, .homeMaintenance): `[30, 7, 1]`
- Ostatní (.warranty, .document, .other): `[7]`

**Příklad:**
```swift
let category = Category.vehicle
print(category.rawValue) // "Vozidlo"
print(category.defaultReminderDays) // [30, 7, 1]
```

---

### `Urgency`

Enum pro barevnou indikaci urgence.

```swift
enum Urgency {
    case critical  // < 7 dní
    case warning   // < 30 dní
    case normal    // 30+ dní
    
    var color: Color { get }
}
```

**Properties:**
- `.critical` → `.red`
- `.warning` → `.orange`
- `.normal` → `.green`

---

## Managers

### `NotificationManager`

Singleton manager pro správu lokálních notifikací.

```swift
@MainActor
final class NotificationManager {
    static let shared: NotificationManager
    
    func requestAuthorization() async -> Bool
    func scheduleNotifications(for item: TrackedItem) async
    func cancelNotifications(for item: TrackedItem) async
    func cancelAllNotifications()
}
```

**Metody:**

#### `requestAuthorization()`
Požádá uživatele o oprávnění k notifikacím.

```swift
let granted = await NotificationManager.shared.requestAuthorization()
if granted {
    print("Notifikace povoleny")
}
```

**Returns:** `Bool` - `true` pokud povoleno, `false` pokud zamítnuto

---

#### `scheduleNotifications(for:)`
Naplánuje notifikace pro danou položku podle její kadence.

```swift
Task {
    await NotificationManager.shared.scheduleNotifications(for: item)
}
```

**Parameters:**
- `item: TrackedItem` - položka, pro kterou plánovat notifikace

**Behavior:**
- Automaticky zruší staré notifikace pro tuto položku
- Naplánuje nové notifikace podle `item.reminderDays`
- Přeskočí notifikace s datem v minulosti
- Přidá `itemId` do `userInfo` pro identifikaci

**Notifikační formát:**
- 1 den před: "Zítra vyprší lhůta" + název položky
- Ostatní: Název položky + "Vyprší za X dní"

---

#### `cancelNotifications(for:)`
Zruší všechny naplánované notifikace pro danou položku.

```swift
Task {
    await NotificationManager.shared.cancelNotifications(for: item)
}
```

**Parameters:**
- `item: TrackedItem` - položka, jejíž notifikace zrušit

**Use case:** Volat před smazáním položky

---

#### `cancelAllNotifications()`
Zruší všechny naplánované notifikace aplikace.

```swift
NotificationManager.shared.cancelAllNotifications()
```

**Use case:** Debug, reset, atd.

---

### `CalendarManager`

Singleton manager pro export do systémového Kalendáře.

```swift
@MainActor
final class CalendarManager {
    static let shared: CalendarManager
    
    func requestAccess() async -> Bool
    func exportToCalendar(item: TrackedItem) async throws
}
```

**Metody:**

#### `requestAccess()`
Požádá uživatele o oprávnění k přístupu do kalendáře.

```swift
let hasAccess = await CalendarManager.shared.requestAccess()
if !hasAccess {
    // Zobraz chybovou hlášku
}
```

**Returns:** `Bool` - `true` pokud povoleno, `false` pokud zamítnuto

---

#### `exportToCalendar(item:)`
Vytvoří all-day event v defaultním kalendáři.

```swift
do {
    try await CalendarManager.shared.exportToCalendar(item: item)
    // Success
} catch {
    // Zobraz chybu
}
```

**Parameters:**
- `item: TrackedItem` - položka k exportu

**Event properties:**
- Název: `item.title`
- Datum: `item.dueDate` (all-day)
- Poznámka: `item.note` (pokud existuje)
- Alarm: 24 hodin před událostí
- Kalendář: defaultní pro nové události

**Throws:** Error pokud nelze vytvořit event

---

## Views

### `ContentView`

Hlavní seznam všech položek.

```swift
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackedItem.dueDate, order: .forward) private var items: [TrackedItem]
    @State private var showingAddSheet: Bool
}
```

**Features:**
- Zobrazení seznamu položek seřazených podle `dueDate`
- Empty state pro prázdný seznam
- Swipe-to-delete
- Tlačítko "+" pro přidání nové položky
- NavigationLink do `ItemDetailView`

**Layout:**
- NavigationStack
- List s ItemRow pro každou položku
- Toolbar s plus tlačítkem

---

### `ItemRow`

Jeden řádek v seznamu položek.

```swift
struct ItemRow: View {
    let item: TrackedItem
}
```

**Layout:**
- HStack
- Barevná tečka (urgency indicator)
- VStack s názvem a datem
- Accessibility label pro tečku

---

### `AddEditItemView`

Formulář pro přidání nové nebo editaci existující položky.

```swift
struct AddEditItemView: View {
    let modelContext: ModelContext
    let itemToEdit: TrackedItem?
    
    @State private var title: String
    @State private var category: Category
    @State private var dueDate: Date
    @State private var note: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var photoData: Data?
}
```

**Parameters:**
- `modelContext` - pro vložení/úpravu
- `itemToEdit` - pokud editace, jinak `nil`

**Features:**
- Text field pro název
- Picker pro kategorii
- Date picker pro datum
- Text editor pro poznámku
- PhotosPicker pro fotku
- Náhled fotky s možností smazání
- Validace (save disabled pokud název prázdný)

**Presentation:** Modal sheet

**Příklad:**
```swift
.sheet(isPresented: $showingAddSheet) {
    AddEditItemView(modelContext: modelContext)
}

// Nebo pro editaci:
.sheet(isPresented: $showingEditSheet) {
    AddEditItemView(modelContext: modelContext, itemToEdit: item)
}
```

---

### `ItemDetailView`

Zobrazení detailu jedné položky.

```swift
struct ItemDetailView: View {
    let item: TrackedItem
    let modelContext: ModelContext
    
    @State private var showingEditSheet: Bool
    @State private var showingDeleteAlert: Bool
    @State private var showingPhotoPreview: Bool
    @State private var showingCalendarSuccess: Bool
    @State private var showingCalendarError: Bool
}
```

**Parameters:**
- `item` - položka k zobrazení
- `modelContext` - pro smazání

**Features:**
- Zobrazení všech dat položky
- Barevná tečka s urgencí
- Fotka dokladu (pokud existuje)
- Tlačítko "Upravit"
- Tlačítko "Smazat" (s confirmation alertem)
- Tlačítko "Přidat do kalendáře"
- Fullscreen náhled fotky

**Actions:**
- Edit → otevře `AddEditItemView` v edit módu
- Delete → zobrazí alert a smaže položku + zruší notifikace
- Add to Calendar → exportuje do kalendáře s error handlingem

---

### `PhotoPreviewView`

Fullscreen náhled fotky dokladu.

```swift
struct PhotoPreviewView: View {
    let image: UIImage
}
```

**Presentation:** Modal sheet

---

## SwiftData Queries

### Základní query (už použitá v ContentView)

```swift
@Query(sort: \TrackedItem.dueDate, order: .forward) 
private var items: [TrackedItem]
```

### Budoucí rozšíření - filtry

```swift
// Podle kategorie
@Query(filter: #Predicate<TrackedItem> { $0.category == .vehicle })
private var vehicleItems: [TrackedItem]

// Vypršené položky
@Query(filter: #Predicate<TrackedItem> { $0.dueDate < Date() })
private var expiredItems: [TrackedItem]

// Kombinace
@Query(
    filter: #Predicate<TrackedItem> { 
        $0.category == .vehicle && $0.dueDate > Date() 
    },
    sort: \TrackedItem.dueDate
)
private var upcomingVehicleItems: [TrackedItem]
```

---

## Best Practices

### 1. Vždy používej Task pro async operace

```swift
// ✅ Správně
Button("Uložit") {
    Task {
        await NotificationManager.shared.scheduleNotifications(for: item)
    }
}

// ❌ Špatně - runtime warning
Button("Uložit") {
    await NotificationManager.shared.scheduleNotifications(for: item)
}
```

### 2. Aktualizuj updatedAt při editaci

```swift
func saveItem() {
    item.title = newTitle
    item.updatedAt = Date()  // ← důležité!
}
```

### 3. Zruš notifikace před smazáním

```swift
func deleteItem() {
    Task {
        await NotificationManager.shared.cancelNotifications(for: item)
    }
    modelContext.delete(item)
}
```

### 4. Error handling pro kalendář

```swift
do {
    let hasAccess = await CalendarManager.shared.requestAccess()
    guard hasAccess else {
        // Zobraz error
        return
    }
    try await CalendarManager.shared.exportToCalendar(item: item)
    // Success
} catch {
    // Zobraz error
}
```

### 5. Accessibility labels

```swift
Button("Smazat") { }
    .accessibilityLabel("Smazat položku \(item.title)")
```

---

## Testing

### Unit testy (budoucí rozšíření)

```swift
import Testing

@Suite("TrackedItem Tests")
struct TrackedItemTests {
    @Test("Urgency pro blízké datum")
    func urgencyForNearDate() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let item = TrackedItem(title: "Test", category: .vehicle, dueDate: tomorrow)
        
        #expect(item.urgency == .critical)
    }
    
    @Test("Default reminder days pro kritickou kategorii")
    func defaultReminderDays() {
        let item = TrackedItem(
            title: "Test", 
            category: .vehicle, 
            dueDate: Date()
        )
        
        #expect(item.reminderDays == [30, 7, 1])
    }
}
```

### Preview s daty

```swift
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TrackedItem.self, configurations: config)
    let context = container.mainContext
    
    // Vložit testovací data
    let item = TrackedItem(
        title: "Test položka",
        category: .vehicle,
        dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    )
    context.insert(item)
    
    return ContentView()
        .modelContainer(container)
}
```

---

## Časté use cases

### Vytvoření nové položky

```swift
let item = TrackedItem(
    title: "STK",
    category: .vehicle,
    dueDate: dateFromPicker
)
modelContext.insert(item)

Task {
    await NotificationManager.shared.scheduleNotifications(for: item)
}
```

### Editace položky

```swift
item.title = newTitle
item.dueDate = newDate
item.updatedAt = Date()

Task {
    await NotificationManager.shared.scheduleNotifications(for: item)
}
```

### Smazání položky

```swift
Task {
    await NotificationManager.shared.cancelNotifications(for: item)
}
modelContext.delete(item)
```

### Přidání fotky

```swift
if let data = try? await photoItem.loadTransferable(type: Data.self) {
    item.photoData = data
}
```

### Export do kalendáře

```swift
let hasAccess = await CalendarManager.shared.requestAccess()
guard hasAccess else { return }

do {
    try await CalendarManager.shared.exportToCalendar(item: item)
    showSuccess = true
} catch {
    showError = true
}
```

---

## Limits & Constraints

### SwiftData
- Max velikost `Data` pro fotku: ~10MB doporučeno
- Není optimalizováno pro tisíce položek (pro MVP stačí)

### Notifications
- Max 64 naplánovaných notifikací per app (iOS limit)
- Pro více položek potřeba chytřejší scheduling

### Calendar
- Vyžaduje default kalendář (pokud neexistuje, fail)
- Export vytváří duplicity při opakovaném volání

### Photos
- Fotky nejsou komprimované v MVP
- Může zabírat hodně storage

---

Toto je kompletní API dokumentace pro Kontrolka MVP. Pro další rozšíření viz [Examples.swift](Examples.swift).
