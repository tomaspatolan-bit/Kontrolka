# 🤖 Claude Context - Kontrolka MVP Data Model

Tento soubor obsahuje kompletní context pro AI asistenta (Claude) o aplikaci Kontrolka MVP.

**Poslední aktualizace:** 04.09.2026 - Liquid Glass Navigation ✨  
**Verze:** 1.2.0 (Liquid Glass Update)

---

## 📱 O aplikaci

**Název:** Kontrolka  
**Typ:** Nativní iOS aplikace  
**Cíl:** Sledování dlouhodobých lhůt (STK, pojistky, revize, doklady)  
**Target:** iOS 17+  
**Framework:** SwiftUI + SwiftData  
**Jazyk:** Čeština (MVP)  
**Storage:** Lokální (žádný cloud sync v MVP)  
**UI Style:** Moderní card-based design s liquid glass bottom bar ✨

---

## 🏗 Architektura

### Tech Stack
- **UI:** SwiftUI (iOS 17+)
- **Persistence:** SwiftData
- **Notifications:** UserNotifications (lokální)
- **Calendar:** EventKit
- **Photos:** PhotosUI
- **Concurrency:** Swift async/await
- **Dependencies:** Žádné (pure native)

### Design Patterns
- **MVVM** - Views + SwiftData models
- **Singleton** - NotificationManager, CalendarManager
- **Repository** - SwiftData jako data layer
- **Dependency Injection** - ModelContext předáván přes views

---

## 📊 Data Model

### TrackedItem (SwiftData @Model)

```swift
@Model
final class TrackedItem {
    // Required fields
    var id: UUID                        // Unikátní identifikátor
    var title: String                   // Název položky
    var category: Category              // Kategorie (enum)
    var dueDate: Date                   // Datum vypršení
    var createdAt: Date                 // Datum vytvoření
    var updatedAt: Date                 // Datum poslední úpravy
    
    // Optional fields
    var note: String?                   // Poznámka
    var photoData: Data?                // Fotka dokladu jako Data
    var customReminderDays: [Int]?      // Custom notifikační kadence
    
    // Computed property
    var reminderDays: [Int] {
        customReminderDays ?? category.defaultReminderDays
    }
}
```

### Category (Enum)

```swift
enum Category: String, Codable, CaseIterable {
    case vehicle = "Vozidlo"              // STK, dálniční známka
    case insurance = "Pojištění"          // Povinné ručení, havarijní
    case homeMaintenance = "Domácnost"    // Revize komína, kotle
    case warranty = "Záruka"              // Záruky na spotřebiče
    case document = "Doklad"              // Řidičák, občanka, pas
    case other = "Ostatní"                // Ostatní položky
    
    var defaultReminderDays: [Int] {
        switch self {
        case .vehicle, .insurance, .homeMaintenance:
            return [30, 7, 1]  // Kritické: 30, 7, 1 den před
        case .warranty, .document, .other:
            return [7]          // Ostatní: 7 dní před
        }
    }
    
    // SF Symbol ikony pro UI
    var iconName: String {
        switch self {
        case .vehicle: return "car.fill"
        case .insurance: return "shield.fill"
        case .homeMaintenance: return "wrench.and.screwdriver.fill"
        case .warranty: return "checkmark.seal.fill"
        case .document: return "person.text.rectangle.fill"
        case .other: return "tray.fill"
        }
    }
}
```

### Urgency (Enum)

```swift
enum Urgency {
    case critical  // < 7 dní do vypršení
    case warning   // < 30 dní do vypršení
    case normal    // 30+ dní do vypršení
    
    var color: Color {
        switch self {
        case .critical: return .red
        case .warning: return .orange
        case .normal: return .green
        }
    }
}
```

### Extensions

```swift
extension TrackedItem {
    // Urgence podle zbývajících dní
    var urgency: Urgency {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        if daysRemaining < 7 { return .critical }
        else if daysRemaining < 30 { return .warning }
        else { return .normal }
    }
    
    // Formátované datum
    var dueDateFormatted: String {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        if daysRemaining < 0 { return "Vypršelo před \(abs(daysRemaining)) dny" }
        else if daysRemaining == 0 { return "Vyprší dnes" }
        else if daysRemaining == 1 { return "Vyprší zítra" }
        else if daysRemaining <= 30 { return "Vyprší za \(daysRemaining) dní" }
        else { return dueDate.formatted(date: .abbreviated, time: .omitted) }
    }
}
```

---

## 🎯 Managers (Singletons)

### NotificationManager

**Zodpovědnost:** Správa lokálních notifikací

```swift
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    // Požádat o oprávnění
    func requestAuthorization() async -> Bool
    
    // Naplánovat notifikace pro položku
    func scheduleNotifications(for item: TrackedItem) async
    
    // Zrušit notifikace pro položku
    func cancelNotifications(for item: TrackedItem) async
    
    // Zrušit všechny notifikace
    func cancelAllNotifications()
}
```

**Notifikační logika:**
- Kritické kategorie (vehicle, insurance, homeMaintenance): 30, 7, 1 den před
- Ostatní kategorie (warranty, document, other): 7 dní před
- Text: "Zítra vyprší lhůta" + název (pro 1 den) nebo Název + "Vyprší za X dní"
- Přidá itemId do userInfo pro tracking
- Přeskočí notifikace v minulosti

### CalendarManager

**Zodpovědnost:** Export do systémového Kalendáře

```swift
@MainActor
final class CalendarManager {
    static let shared = CalendarManager()
    
    // Požádat o oprávnění
    func requestAccess() async -> Bool
    
    // Exportovat položku do kalendáře
    func exportToCalendar(item: TrackedItem) async throws
}
```

**Export logika:**
- All-day event na dueDate
- Název: item.title
- Poznámka: item.note (pokud existuje)
- Alarm: 24 hodin před událostí
- Kalendář: defaultCalendarForNewEvents

---

## 🖼 Views (Modernizované UI)

### Root View: MainTabView

**Účel:** Hlavní container s custom bottom bar navigací

**UI Komponenty:**
- Custom liquid glass bottom bar (CustomTabBar) ✨ **AKTUALIZOVÁNO**
- 4 taby: Seznam (.list), Kalendář (.calendar), Nové (.placeholder), Nastavení (.settings) ✨ **AKTUALIZOVÁNO**
- Vystouplé plus tlačítko uprostřed s liquid glass efektem ✨ **AKTUALIZOVÁNO**
- Confirmation dialog pro výběr způsobu přidání

**AppTab enum:**
```swift
enum AppTab: Hashable {
    case list
    case calendar      // ✨ NOVÝ
    case placeholder   // ✨ NOVÝ
    case settings
}
```

**State:**
```swift
@State private var selectedTab: AppTab = .list
@State private var showingAddOptions = false
@State private var showingCamera = false
@State private var showingAddSheet = false
@State private var capturedImage: UIImage?
```

**Plus tlačítko → Confirmation Dialog:**
1. "Přidat ručně" → AddEditItemView bez fotky
2. "Vyfotit doklad" → CameraCaptureView → AddEditItemView s přednahranou fotkou
3. "Zrušit"

**Custom Bottom Bar:** ✨ **AKTUALIZOVÁNO**
- Plovoucí liquid glass bar (Capsule tvar, okraje 16pt od hran)
- `.ultraThinMaterial` + `.background.opacity(0.5)` = průhledné sklo
- 4 tab buttons: Seznam (list.bullet), Kalendář (calendar), Nové (sparkles), Nastavení (gearshape.fill)
- Vystouplý plus button uprostřed:
  - Velikost: 60x60
  - Offset: -40pt nad bar
  - Gradient + glass material overlay
  - Shadow: blue @ 30%, radius 12
- Aktivní tab liquid glass focus:
  - Skleněný kruh (50x50) s modrým tintem (opacity 0.15)
  - Větší ikona (24pt) vs neaktivní (22pt)
  - Animovaný přechod: `.spring(response: 0.3, dampingFraction: 0.7)`
- Respektuje `accessibilityReduceTransparency` - spadne na `.regularMaterial`

---

### 1. ContentView (Hlavní seznam)

**Účel:** Zobrazení všech položek jako karet seřazených podle dueDate

**UI Komponenty:**
- NavigationStack
- List
- TrackedItemCardView (custom card component) ✨ **AKTUALIZOVÁNO**
- Empty state (ContentUnavailableView)
- NavigationDestination → ItemDetailView

**Query:**
```swift
@Query(sort: \TrackedItem.dueDate, order: .forward) 
private var items: [TrackedItem]
```

**Features:**
- Řazení podle nejbližšího dueDate
- Karty s ikonami podle kategorie ✨ **NOVÉ**
- Barevná pozadí ikon podle urgence ✨ **NOVÉ**
- Thumbnail fotky na kartě (pokud existuje) ✨ **NOVÉ**
- Formátované datum ("za X dní")
- Swipe-to-delete
- Hidden list separators, clear row background
- Navigation přes NavigationLink value binding

**TrackedItemCardView struktura:** ✨ **NOVÉ**
```
┌─────────────────────────────────────────────────────┐
│  [◉ Ikona]  Název položky               [📷]  ›    │
│             Kategorie                               │
│             Datum (barevně)                         │
└─────────────────────────────────────────────────────┘

Layout:
- HStack (spacing: 14)
- Ikona v kruhu (44x44) s barvou podle urgence
- VStack s texty (spacing: 3)
- Optional thumbnail (36x36) rounded
- Chevron right
- Padding: 12, Corner radius: 16
- Background: secondarySystemGroupedBackground
```

**Ikony podle kategorie:**
- vehicle: `car.fill`
- insurance: `shield.fill`
- homeMaintenance: `wrench.and.screwdriver.fill`
- warranty: `checkmark.seal.fill`
- document: `person.text.rectangle.fill`
- other: `tray.fill`

---

### 2. AddEditItemView (Přidání/Úprava)

**Účel:** Formulář pro vytvoření nové nebo editaci existující položky

**UI Komponenty:**
- NavigationStack (v sheet)
- Form
- TextField (název)
- Picker (kategorie)
- DatePicker (datum vypršení)
- TextField (poznámka, volitelné)
- PhotosPicker (fotka, volitelné)
- Preview fotky s tlačítkem Odstranit

**State:**
```swift
@State private var title: String
@State private var category: Category
@State private var dueDate: Date
@State private var note: String
@State private var selectedPhotoItem: PhotosPickerItem?
@State private var photoData: Data?
@State private var showingPhotoPreview: Bool
```

**Init Signatura:** ✨ **AKTUALIZOVÁNO**
```swift
init(modelContext: ModelContext, initialPhotoData: Data? = nil, itemToEdit: TrackedItem? = nil)
```

**Toolbar:**
- Left: "Zrušit" button
- Right: "Uložit" button (disabled pokud title.isEmpty)

**Logika:**
- Init přijímá `initialPhotoData` pro přednahranou fotku z kamery ✨ **NOVÉ**
- Init přijímá `itemToEdit: TrackedItem?` pro editaci
- Pokud itemToEdit nil → vytvoří novou položku
- Pokud itemToEdit non-nil → edituje existující
- Pokud initialPhotoData → zobrazí fotku hned po otevření ✨ **NOVÉ**
- Po uložení → scheduleNotifications
- PhotosPicker onChange → loadTransferable(type: Data.self)

---

### 3. ItemDetailView (Detail položky)

**Účel:** Zobrazení všech informací o položce + akce

**UI Komponenty:**
- List
- DetailRow (custom component)
- Barevná tečka s urgencí
- Fotka (pokud existuje)
- Button "Přidat do kalendáře"
- Button "Upravit"
- Button "Smazat" (destructive)

**State:**
```swift
@State private var showingEditSheet: Bool
@State private var showingDeleteAlert: Bool
@State private var showingPhotoPreview: Bool
@State private var showingCalendarSuccess: Bool
@State private var showingCalendarError: Bool
@State private var calendarErrorMessage: String
```

**Akce:**
1. **Upravit:** Otevře AddEditItemView v sheet s itemToEdit
2. **Smazat:** Zobrazí alert → zruší notifikace → smaže z DB → dismiss
3. **Přidat do kalendáře:** Požádá o oprávnění → export → zobrazí success/error alert

---

### 4. CameraCaptureView (Nová komponenta) ✨

**Účel:** UIImagePickerController wrapper pro fotoaparát

**Typ:** UIViewControllerRepresentable

**Callback:**
```swift
let onImageCaptured: (UIImage) -> Void
```

**Použití:**
```swift
.sheet(isPresented: $showingCamera) {
    CameraCaptureView { image in
        capturedImage = image
        showingAddSheet = true
    }
}
```

**Coordinator:**
- Implementuje UIImagePickerControllerDelegate
- didFinishPickingMediaWithInfo → volá onImageCaptured
- didCancel → dismiss

---

### 5. CustomTabBar (Nová komponenta) ✨

**Účel:** Plovoucí liquid glass bottom bar s 4 taby

**Props:**
```swift
@Binding var selectedTab: AppTab
let onAddTapped: () -> Void
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency
```

**Layout:** ✨ **AKTUALIZOVÁNO v1.2.0**
```
[Seznam] [Kalendář]  [PLUS]  [Nové] [Nastavení]
    ↓        ↓          ↓       ↓        ↓
   22pt    22pt      60x60    22pt     22pt
  glass   glass     gradient  glass    glass
  focus   focus      glass    focus    focus
```

**Struktura:**
- HStack s 4 TabBarButton komponenty
- `Spacer().frame(width: 80)` mezi Kalendářem a Novým (prostor pro plus)
- Plus tlačítko přes `.overlay(alignment: .top)` - přesné centrování
- Background: Capsule s `.ultraThinMaterial` + `.background.opacity(0.5)`
- Shadow: `.black.opacity(0.12), radius: 12, y: 4`
- Padding: horizontal 16pt, bottom 10pt

**Plus tlačítko:**
- Circle 60x60
- Gradient: `[Color.blue, Color.blue.opacity(0.8)]`
- Material overlay: `.ultraThinMaterial` (opacity 0.3)
- Icon: plus (26pt, semibold)
- Shadow: `.blue.opacity(0.3), radius: 12, y: 6`
- Offset: -40pt (vystouplý nad bar)

**TabBarButton - Liquid Glass Focus:** ✨ **NOVÉ**
```swift
if isSelected && !reduceTransparency {
    Circle()
        .fill(.ultraThinMaterial)
        .frame(width: 50, height: 50)
        .overlay {
            Circle().fill(.blue.opacity(0.15))
        }
}
```
- Skleněný kruh kolem ikony aktivního tabu
- Modrý tint pro vizuální feedback
- Animovaný přechod pomocí spring animation
- Ikona: 24pt (selected) vs 22pt (unselected)
- Text: `.semibold` (selected) vs `.regular` (unselected)
- `.symbolRenderingMode(.hierarchical)` pro SF Symbols

**Accessibility:**
- Respektuje `reduceTransparency`
- Spadne na `.regularMaterial` při zapnutém
- Pevné pozadí `Color.blue.opacity(0.9)` pro plus tlačítko
- `.buttonStyle(.plain)` pro lepší touch handling

---

### 6. SettingsView (Placeholder) ✨

**Účel:** Nastavení aplikace (placeholder pro MVP)

**Obsah:**
- Section "O aplikaci": Verze (1.0.0)
- Section "Systém": Link na systémová oprávnění
- NavigationTitle: "Nastavení"

---

### 7. CalendarTabView (Nová komponenta) ✨ **v1.2.0**

**Účel:** Měsíční kalendář s tečkami na dnech s položkami

**UI Komponenty:**
- NavigationStack
- Měsíční navigace (šipky vlevo/vpravo)
- LazyVGrid 7 sloupců (Po-Ne)
- DayItemsSheet pro zobrazení položek vybraného dne

**State:**
```swift
@State private var currentMonth: Date
@State private var selectedDayItems: [TrackedItem]?
@State private var showingDaySheet: Bool
```

**Features:**
- **Měsíční mřížka:** 7 sloupců (pondělí → neděle)
- **Dnešní den:** Modrý background + tučné písmo
- **Tečky podle urgence:**
  - Pokud den má položky → zobrazí tečku (6x6 Circle)
  - Barva = nejnaléhavější položka toho dne:
    - `.critical` (červená) vítězí
    - `.warning` (oranžová) druhá
    - `.normal` (zelená) default
- **Tap na den:** Otevře `.sheet` se seznamem položek
- **Navigace měsíců:** Šipky pro předchozí/další měsíc
- **Read-only:** Žádný zápis do systémového Kalendáře

**DayItemsSheet:**
- NavigationStack + List
- Recykluje `TrackedItemCardView` pro konzistentní design
- NavigationLink do `ItemDetailView`
- Toolbar: tlačítko "Zavřít"
- Title: formátované datum (např. "15. září 2026")

**Logika:**
```swift
// Zjistit položky pro den
func items(for date: Date) -> [TrackedItem] {
    items.filter { calendar.isDate($0.dueDate, inSameDayAs: date) }
}

// Najít nejnaléhavější barvu
func mostUrgentColor(for items: [TrackedItem]) -> Color? {
    if items.contains(where: { $0.urgency == .critical }) { return .red }
    if items.contains(where: { $0.urgency == .warning }) { return .orange }
    return .green
}
```

---

### 8. PlaceholderTabView (Nová komponenta) ✨ **v1.2.0**

**Účel:** Placeholder pro budoucí funkci

**UI:**
- NavigationStack
- ContentUnavailableView:
  - Ikona: `sparkles`
  - Nadpis: "Připravujeme"
  - Popis: "Tato funkce bude dostupná v příští verzi"
- NavigationTitle: "Nové"

**Use case:** Rezervace místa pro budoucí feature (např. AI asistent, statistiky, atd.)

**DetailRow struktura:**
```
[Label]               [Value]
Název                 STK - Škoda Octavia
Kategorie             Vozidlo
Datum vypršení        15. září 2026
Stav                  [● Oranžová] Vyprší za 15 dní
```

**Kalendář tab struktura:** ✨ **NOVÉ v1.2.0**
```
┌────────────────────────────────────┐
│  [<]  Září 2026  [>]               │  ← Navigace měsíců
├────────────────────────────────────┤
│  Po  Út  St  Čt  Pá  So  Ne        │  ← Header
├────────────────────────────────────┤
│   1   2   3   4  [5]  6   7        │  ← Dny
│       ●       ●   ●                 │  ← Tečky (urgence)
│   8   9  10  11  12  13  14        │
│       ●                             │
│  15  16  17  18  19  20  21        │
│   ●                                 │
└────────────────────────────────────┘

Legend:
[5] = Dnešní den (modrý background)
 ●  = Položky tento den (barva = nejnaléhavější)
Tap na den → Sheet se seznamem položek
```

---

## 🔔 Notifikace Flow

### 1. První spuštění
```
App launch → ContentView.task → requestAuthorization() → iOS zobrazí dialog
```

### 2. Vytvoření položky
```
AddEditItemView.saveItem() 
→ insert do SwiftData 
→ Task { await scheduleNotifications(for: newItem) }
→ iOS naplánuje lokální notifikace
```

### 3. Úprava položky
```
AddEditItemView.saveItem()
→ update SwiftData properties
→ Task { await scheduleNotifications(for: itemToEdit) }
→ cancelNotifications (staré) → scheduleNotifications (nové)
```

### 4. Smazání položky
```
ItemDetailView.deleteItem() nebo ContentView swipe-to-delete
→ Task { await cancelNotifications(for: item) }
→ modelContext.delete(item)
```

### Notifikační formát

**1 den před:**
```
Title: "Zítra vyprší lhůta"
Body: "STK - Škoda Octavia"
```

**Ostatní:**
```
Title: "STK - Škoda Octavia"
Body: "Vyprší za 7 dní"
```

---

## 📅 Calendar Export Flow

### 1. Uživatel klikne "Přidat do kalendáře"
```swift
ItemDetailView → exportToCalendar() async
→ requestAccess() → iOS zobrazí dialog
→ if denied: zobrazí error alert
→ if granted: exportToCalendar(item:)
```

### 2. Export do kalendáře
```swift
CalendarManager.exportToCalendar(item:)
→ Create EKEvent
→ event.title = item.title
→ event.startDate = item.dueDate
→ event.endDate = item.dueDate
→ event.isAllDay = true
→ event.notes = item.note
→ event.addAlarm(relativeOffset: -86400) // 24h před
→ event.calendar = defaultCalendarForNewEvents
→ eventStore.save(event)
```

### 3. Success/Error handling
```swift
do {
    try await CalendarManager.shared.exportToCalendar(item: item)
    showingCalendarSuccess = true
} catch {
    calendarErrorMessage = "Nepodařilo se přidat..."
    showingCalendarError = true
}
```

---

## 🎨 Design Principy

### Apple HIG Compliant
- Nativní SwiftUI komponenty (List, Form, NavigationStack)
- Systémové fonty (.body, .headline, .subheadline)
- Systémové barvy (automatický Dark Mode)
- SF Symbols ikony
- Dynamic Type support
- VoiceOver accessibility labels

### Minimalistický Design
- Pouze 3 obrazovky (žádná tab bar)
- Hodně prázdného prostoru (spacing, padding)
- Barva jen pro urgenci (červená/oranžová/zelená)
- Tlumené ostatní barvy (secondary, tertiary)

### UX Patterns
- Empty state pro prázdný seznam
- Confirmation alerts před destruktivními akcemi
- Success/error alerting pro async operace
- Swipe gestures (swipe-to-delete)
- Plovoucí liquid glass bottom bar ✨ **NOVÉ v1.2.0**
- Liquid glass focus na aktivní tab ✨ **NOVÉ v1.2.0**
- Animované přechody mezi taby ✨ **NOVÉ v1.2.0**
- Confirmation dialog pro výběr způsobu přidání ✨ **v1.1.0**
- Card-based list design místo simple rows ✨ **v1.1.0**
- Měsíční kalendář s tečkami podle urgence ✨ **NOVÉ v1.2.0**

---

## ⚙️ Configuration

### Info.plist Required Keys

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.</string>

<key>NSCameraUsageDescription</key>
<string>Kontrolka potřebuje přístup k fotoaparátu, abys mohl vyfotit doklad.</string>

<key>NSCalendarsUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>

<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>
```

**DŮLEŽITÉ:** NSCameraUsageDescription je nově povinné pro CameraCaptureView ✨

### SwiftData Schema

```swift
let schema = Schema([
    TrackedItem.self,
])
let modelConfiguration = ModelConfiguration(
    schema: schema, 
    isStoredInMemoryOnly: false  // Persistent storage
)
```

---

## 🧪 Testing Scenarios

### Smoke Test (5 min)
1. Spustit app → povolit notifikace
2. Přidat položku (název, kategorie, datum)
3. Otevřít detail
4. Editovat položku
5. Smazat položku

### Full Test (15 min)
1. Všech 6 kategorií
2. Různá data (minulost, dnes, týden, měsíc, rok)
3. S fotkou / bez fotky
4. S poznámkou / bez poznámky
5. Export do kalendáře → ověřit v Kalendář app
6. Zkontrolovat notifikace v Nastavení → Notifikace → Kontrolka
7. Dark Mode switch
8. VoiceOver navigace
9. **Plus tlačítko v bottom bar** → dialog zobrazí ✨ **NOVÉ**
10. **"Vyfotit doklad"** → otevře kameru → fotka se přednahraje ✨ **NOVÉ**
11. **Karty zobrazují ikony** podle kategorie ✨ **NOVÉ**
12. **Thumbnail fotek** na kartách (pokud existují) ✨ **NOVÉ**
9. Swipe-to-delete
10. Landscape orientace

---

## 🚫 Vědomá Omezení MVP

### NENÍ implementováno (záměrně)
- ❌ OCR čtení data z fotky (Vision framework) → post-MVP
- ❌ Batching notifikací (více položek = 1 souhrnná notifikace) → post-MVP
- ❌ Cloud sync (CloudKit) → post-MVP
- ❌ Rodinné sdílení → post-MVP
- ❌ Účty a přihlášení → post-MVP
- ❌ Push notifikace ze serveru → MVP jen lokální
- ❌ Grafy a statistiky → podle spec ne v MVP
- ❌ Lokalizace → MVP jen čeština
- ❌ Komprese fotek → post-MVP optimization
- ❌ Widget → post-MVP
- ❌ Apple Watch app → post-MVP
- ❌ Opakující se události → post-MVP

### ✅ JE implementováno (modernizované UI)
- ✅ Plovoucí liquid glass bottom bar s 4 taby ✨ **NOVÉ v1.2.0**
- ✅ Liquid glass focus efekt na aktivní záložce ✨ **NOVÉ v1.2.0**
- ✅ Animované přechody mezi taby ✨ **NOVÉ v1.2.0**
- ✅ CalendarTabView - měsíční kalendář s tečkami ✨ **NOVÉ v1.2.0**
- ✅ PlaceholderTabView - rezervace pro budoucí funkci ✨ **NOVÉ v1.2.0**
- ✅ Vystouplé plus tlačítko uprostřed s liquid glass ✨ **NOVÉ v1.2.0**
- ✅ Accessibility: reduceTransparency podpora ✨ **NOVÉ v1.2.0**
- ✅ Confirmation dialog "Přidat ručně" / "Vyfotit doklad" ✨ **v1.1.0**
- ✅ CameraCaptureView pro focení dokladů ✨ **v1.1.0**
- ✅ Přednahrání fotky do AddEditItemView z kamery ✨ **v1.1.0**
- ✅ TrackedItemCardView - karty místo simple rows ✨ **v1.1.0**
- ✅ Ikony podle kategorií v kartách ✨ **v1.1.0**
- ✅ Thumbnail fotek na kartách ✨ **v1.1.0**
- ✅ Modernější iconName mapping (wrench.and.screwdriver.fill, atd.) ✨ **v1.1.0**

### JE připraveno v kódu, ale nemá UI
- `customReminderDays` field existuje, ale nelze editovat v UI
- Bude přidáno jako "Pokročilé nastavení" v budoucí verzi

---

## 📂 Struktura Souborů

```
Kontrolka/
├── KontrolkaApp.swift              # @main App entry point (root: MainTabView)
├── Models/
│   ├── Item.swift                  # TrackedItem + Category (+ iconName extension)
│   └── TrackedItemHelpers.swift    # Urgency + extensions (Equatable)
├── Managers/
│   ├── NotificationManager.swift   # Lokální notifikace
│   └── CalendarManager.swift       # EventKit export
├── Views/
│   ├── MainTabView.swift           # Root view s liquid glass bar ✨ **UPDATED v1.2.0**
│   │                               # + CalendarTabView ✨ **NEW v1.2.0**
│   │                               # + PlaceholderTabView ✨ **NEW v1.2.0**
│   │                               # + DayItemsSheet ✨ **NEW v1.2.0**
│   ├── ContentView.swift           # Hlavní seznam (karty)
│   ├── TrackedItemCardView.swift   # Card komponenta (bez chevron) ✨ **FIXED**
│   ├── CustomTabBar.swift          # Liquid glass bottom bar ✨ **UPDATED v1.2.0**
│   ├── CameraCaptureView.swift     # Fotoaparát wrapper
│   ├── AddEditItemView.swift       # Přidání/úprava (+ initialPhotoData)
│   └── ItemDetailView.swift        # Detail položky
└── Examples.swift                  # Testovací data a příklady
```
├── Views/
│   ├── ContentView.swift           # Hlavní seznam
│   ├── AddEditItemView.swift       # Přidání/úprava
│   └── ItemDetailView.swift        # Detail položky
└── Examples.swift                  # Testovací data a příklady
```

---

## 🔄 Common Operations

### Vytvoření nové položky

```swift
let newItem = TrackedItem(
    title: "STK - Škoda Octavia",
    category: .vehicle,
    dueDate: dateFromPicker,
    note: "Objednat 2 týdny předem",
    photoData: photoDataFromPicker
)
modelContext.insert(newItem)

Task {
    await NotificationManager.shared.scheduleNotifications(for: newItem)
}
```

### Editace položky

```swift
item.title = newTitle
item.category = newCategory
item.dueDate = newDate
item.note = newNote
item.photoData = newPhotoData
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

### Export do kalendáře

```swift
let hasAccess = await CalendarManager.shared.requestAccess()
guard hasAccess else { 
    // Zobraz error: "Povolte přístup v Nastavení"
    return 
}

do {
    try await CalendarManager.shared.exportToCalendar(item: item)
    // Zobraz success alert
} catch {
    // Zobraz error alert
}
```

---

## 🐛 Common Issues & Solutions

### App crashne při spuštění
**Příčina:** Chybí Info.plist oprávnění  
**Řešení:** Přidat NSPhotoLibraryUsageDescription, NSCalendarsUsageDescription, NSCalendarsWriteOnlyAccessUsageDescription

### Notifikace se neplánují
**Příčina:** Zamítnuté oprávnění nebo datum v minulosti  
**Řešení:** Zkontrolovat Nastavení → Notifikace → Kontrolka, ověřit že dueDate je v budoucnu

### Fotka se nezobrazuje
**Příčina:** Poškozená Data nebo příliš velká fotka  
**Řešení:** Přidat validaci velikosti, komprimovat před uložením (post-MVP)

### SwiftData nefunguje
**Příčina:** Breaking change v schema bez migrace  
**Řešení:** Smazat app a reinstalovat (development), nebo implementovat migration (production)

### Export do kalendáře selže
**Příčina:** Defaultní kalendář neexistuje  
**Řešení:** Zkontrolovat že eventStore.defaultCalendarForNewEvents není nil

---

## 📊 Performance Notes

### SwiftData
- Optimalizováno pro stovky položek
- Pro tisíce položek zvážit indexy a pagination
- Fotky jako Data mohou zabírat hodně paměti → zvážit file storage

### Notifications
- iOS limit: max 64 naplánovaných notifikací per app
- Pro více položek implementovat chytřejší scheduling
- Batching by vyžadoval centralizovaný scheduler

### UI
- List scrolling: 60fps na většině položek
- Preview fotky: může být pomalý s velkými obrázky
- Form: validace real-time může být pomalá → debounce

---

## 🎯 Post-MVP Roadmap

### v1.1 (Short-term)
1. Batching notifikací
2. Komprese fotek před uložením
3. Validace data (varování při minulém datu)
4. UI pro custom reminder days
5. Export/import backup

### v2.0 (Mid-term)
1. OCR čtení data z fotky (Vision)
2. Šablony položek (předvyplněné kategorie)
3. iOS Widget (WidgetKit)
4. CloudKit sync
5. Lokalizace EN

### v3.0 (Long-term)
1. Apple Watch app
2. Opakující se události
3. Rodinné sdílení (CloudKit)
4. Statistiky a insights
5. iPad optimalizace

---

## 📝 Code Style Guidelines

### Swift
- Idiomatický Swift 5.9+
- Swift Concurrency (async/await) místo Combine
- Guard-let pro unwrapping
- Meaningful variable names (ne zkratky)
- Comments pouze kde nutné (self-documenting code)

### SwiftUI
- Prefer computed properties over functions kde možné
- Extract views pro reusability (ItemRow, DetailRow)
- @State pro local state, @Environment pro shared
- ViewModifier místo copy-paste stylingu

### Architecture
- Single responsibility principle
- Dependency injection (ModelContext)
- Singletons jen pro managers
- No global state (kromě managers)

---

## 🔐 Security & Privacy

### Data Storage
- Vše lokálně (SwiftData SQLite)
- Žádné síťování v MVP
- Žádné analytics v MVP
- Respektování systémových oprávnění

### Permissions
- Request only when needed (just-in-time)
- Vysvětlit proč (usage descriptions)
- Fallback pokud denied
- Nikdy netrackovat denial

---

## ✅ Pre-Production Checklist

- [ ] Všechna 3 Info.plist oprávnění přidána
- [ ] Build bez warningů
- [ ] Otestováno na reálném zařízení
- [ ] Všechny testovací scénáře prošly
- [ ] Dark Mode funguje všude
- [ ] VoiceOver labels na všech interaktivních prvcích
- [ ] Dynamic Type testováno
- [ ] Memory leaks checked (Instruments)
- [ ] Performance profiling (60fps scrolling)
- [ ] App Store metadata připravena

---

**Verze dokumentu:** 1.2.0  
**Datum:** 2026-09-04  
**Status:** ✅ Liquid Glass Navigation Complete  
**Pro použití s:** Claude, ChatGPT, Copilot, nebo jiný AI asistent

---

## 💡 Tips pro AI asistenta

### Když uživatel říká:
- "Přidej..." → Zkontroluj, jestli to není v MVP záměrně vynecháno
- "Nefunguje..." → Nejdřív odkázat na troubleshooting
- "Změň design..." → Připomenout Apple HIG principy
- "Přidej dependency..." → MVP je pure native, zvážit důvod
- "Optimalizuj..." → Nejdřív otestovat reálný problém

### Best Practices:
- Vždycky respektovat SwiftData model (je to single source of truth)
- Vždycky volat scheduleNotifications po změně položky
- Vždycky zrušit notifikace před smazáním položky
- Vždycky aktualizovat updatedAt při editaci
- Vždycky error handling pro async operace (calendar, photos)

### Code Examples Location:
- Examples.swift → příklady všech operací
- API_DOCUMENTATION.md → kompletní API reference
- TROUBLESHOOTING.md → řešení problémů
