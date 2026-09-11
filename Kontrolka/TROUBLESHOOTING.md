# Troubleshooting Guide

## 🐛 Běžné problémy a řešení

### 1. App crashne při otevření PhotosPicker

**Symptom:**
```
This app has crashed because it attempted to access privacy-sensitive data 
without a usage description. The app's Info.plist must contain an 
NSPhotoLibraryUsageDescription key with a string value explaining to the 
user how the app uses this data.
```

**Příčina:** Chybí `NSPhotoLibraryUsageDescription` v Info.plist

**Řešení:**
1. Otevři projekt v Xcode
2. Vyber target → Info
3. Přidej klíč `Privacy - Photo Library Usage Description`
4. Hodnota: `Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.`
5. Clean build folder (Cmd+Shift+K)
6. Rebuild (Cmd+B)

---

### 2. App crashne při exportu do kalendáře

**Symptom:**
```
This app has crashed because it attempted to access privacy-sensitive data 
without a usage description. The app's Info.plist must contain an 
NSCalendarsUsageDescription key...
```

**Příčina:** Chybí calendar usage description keys v Info.plist

**Řešení:**
Přidej oba klíče:
- `NSCalendarsUsageDescription`
- `NSCalendarsWriteOnlyAccessUsageDescription`

Detaily viz [INFO_PLIST_GUIDE.md](INFO_PLIST_GUIDE.md)

---

### 3. SwiftData nefunguje / data se neukládají

**Symptom:** 
- Položky zmizí po restartu aplikace
- Chyba: `Could not create ModelContainer`

**Možné příčiny:**

#### A) Změnil ses schema bez migrace
```swift
// Starý model
@Model class Item { ... }

// Nový model (breaking change)
@Model class TrackedItem { ... }
```

**Řešení:** Smazat aplikaci a reinstalovat
- Na simulátoru: Delete app
- Na zařízení: Long press → Remove App → Delete App

#### B) In-memory container v produkci
```swift
// ❌ Špatně - data se ztratí po restartu
let config = ModelConfiguration(isStoredInMemoryOnly: true)

// ✅ Správně - perzistentní
let config = ModelConfiguration(isStoredInMemoryOnly: false)
```

**Kontrola:** Otevři `KontrolkaApp.swift` a ověř:
```swift
let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
```

---

### 4. Notifikace se neplánují

**Symptom:** 
- Po vytvoření položky žádné notifikace v Nastavení
- Notifikace nepřichází

**Možné příčiny:**

#### A) Zamítnuté oprávnění
**Kontrola:**
```
Nastavení → Notifikace → Kontrolka
```

**Řešení:** Povolit notifikace manuálně

#### B) Datum v minulosti
```swift
// NotificationManager neplánuje notifikace pro minulá data
guard notificationDate > now else { continue }
```

**Kontrola:** Ujisti se, že `dueDate` položky je v budoucnu

#### C) iOS Focus mód blokuje notifikace
**Kontrola:** Vypni Focus módy pro testování

#### D) Notifikace smazané ručně
**Řešení:** Edituj položku a ulož znovu → replánují se

**Debug tip:**
```swift
Task {
    let center = UNUserNotificationCenter.current()
    let pending = await center.pendingNotificationRequests()
    print("📬 Počet naplánovaných notifikací: \(pending.count)")
    for request in pending {
        print("  - \(request.identifier): \(request.content.title)")
    }
}
```

---

### 5. Fotka se nezobrazuje v detailu

**Symptom:**
- Fotka se uložila (PhotosPicker fungoval)
- V detailu není vidět

**Možné příčiny:**

#### A) Fotka příliš velká
**Řešení:** Přidat kompresi před uložením (budoucí zlepšení)

#### B) Poškozená Data
**Debug:**
```swift
if let photoData = item.photoData {
    print("📸 Photo data size: \(photoData.count) bytes")
    if let image = UIImage(data: photoData) {
        print("✅ Image lze vytvořit")
    } else {
        print("❌ Image nelze vytvořit z Data")
    }
}
```

#### C) SwiftData nepersistovalo Data
**Kontrola:** Po uložení restartuj app a zkontroluj, jestli je `photoData` stále non-nil

---

### 6. Export do kalendáře selže bez chyby

**Symptom:**
- Kliknu na "Přidat do kalendáře"
- Zobrazí se success alert
- V Kalendáři nic není

**Možné příčiny:**

#### A) Defaultní kalendář neexistuje
```swift
event.calendar = eventStore.defaultCalendarForNewEvents
// může být nil!
```

**Řešení:** Upravit `CalendarManager.swift`:
```swift
guard let defaultCalendar = eventStore.defaultCalendarForNewEvents else {
    throw CalendarError.noDefaultCalendar
}
event.calendar = defaultCalendar
```

#### B) Event se vytváří v jiném účtu
**Kontrola:** Otevři Kalendář app → Zkontroluj všechny účty (iCloud, Gmail, atd.)

---

### 7. Dark Mode nefunguje správně

**Symptom:**
- V Dark Mode špatná viditelnost
- Barvy se nemění

**Možné příčiny:**

#### A) Používání fixed barev místo systémových
```swift
// ❌ Špatně - nereaguje na Dark Mode
.foregroundColor(.black)

// ✅ Správně - adaptivní
.foregroundColor(.primary)
```

**Kontrola:** Prohledej kód a nahraď fixed barvy systémovými:
- `.black` → `.primary`
- `.gray` → `.secondary`
- `Color(red:green:blue:)` → systémové barvy

#### B) Vlastní assets bez Dark varianty
**Řešení:** Použít jen systémové barvy v MVP

---

### 8. VoiceOver špatně čte obsah

**Symptom:**
- VoiceOver čte nesprávné texty
- Některé prvky nelze vybrat

**Řešení:** Přidat accessibility labels:
```swift
Button("Smazat") { ... }
    .accessibilityLabel("Smazat položku")

Circle()
    .fill(item.urgency.color)
    .accessibilityLabel(urgencyText)
```

**Testování:**
1. Zapni VoiceOver (Settings → Accessibility → VoiceOver)
2. Nebo na simulátoru: Cmd+F5
3. Projdi všechny obrazovky

---

### 9. Swipe-to-delete nefunguje

**Symptom:**
- Při swipe nic nereaguje

**Možná příčina:** `.onDelete` není na `ForEach`, ale na `List`

```swift
// ❌ Špatně
List {
    ForEach(items) { ... }
}
.onDelete(perform: deleteItems)

// ✅ Správně
List {
    ForEach(items) { ... }
        .onDelete(perform: deleteItems)
}
```

---

### 10. Seznam se neaktualizuje po editaci

**Symptom:**
- Edituju položku
- Změny se neuloží / nezobrazí

**Možné příčiny:**

#### A) Zapomněl jsi aktualizovat `updatedAt`
```swift
func saveItem() {
    itemToEdit.title = title
    itemToEdit.updatedAt = Date()  // ← důležité!
}
```

#### B) SwiftData není správně bindovaný
**Kontrola:** `@Query` musí být `private var`, ne `@State`

```swift
// ✅ Správně
@Query(sort: \TrackedItem.dueDate) private var items: [TrackedItem]

// ❌ Špatně
@State private var items: [TrackedItem] = []
```

---

## 🔍 Debugging tipy

### 1. Print debugging pro SwiftData

```swift
import SwiftData

extension ModelContext {
    func debugPrintAllItems() {
        let descriptor = FetchDescriptor<TrackedItem>()
        do {
            let items = try fetch(descriptor)
            print("📦 SwiftData obsahuje \(items.count) položek:")
            for item in items {
                print("  - \(item.title) (due: \(item.dueDate.formatted()))")
            }
        } catch {
            print("❌ Chyba při čtení: \(error)")
        }
    }
}

// Použití
modelContext.debugPrintAllItems()
```

### 2. Print debugging pro notifikace

```swift
extension NotificationManager {
    func debugPrintScheduledNotifications() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        
        print("🔔 Naplánované notifikace: \(requests.count)")
        for request in requests {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let date = trigger.nextTriggerDate() {
                print("  - \(request.content.title)")
                print("    Kdy: \(date.formatted())")
            }
        }
    }
}

// Použití
Task {
    await NotificationManager.shared.debugPrintScheduledNotifications()
}
```

### 3. Breakpoints

Nastav breakpointy v klíčových místech:
- `ContentView.body` - pro kontrolu rendering
- `AddEditItemView.saveItem()` - pro kontrolu ukládání
- `NotificationManager.scheduleNotifications()` - pro kontrolu plánování

### 4. Memory Graph Debugger

Kontrola memory leaks:
1. Spusť app
2. Xcode → Debug → Memory Graph
3. Hledej circular references

### 5. View Hierarchy Debugger

Kontrola UI layoutu:
1. Spusť app
2. Xcode → Debug → View Debugging → Capture View Hierarchy
3. Prohlédni 3D view hierarchy

---

## 🧪 Testovací scénáře

### Quick smoke test (5 min)
1. [ ] Spustit app
2. [ ] Přidat položku
3. [ ] Otevřít detail
4. [ ] Editovat položku
5. [ ] Smazat položku
6. [ ] Swipe-to-delete
7. [ ] Přidat fotku
8. [ ] Export do kalendáře

### Full test (15 min)
1. [ ] Všechny kategorie
2. [ ] Různá data (minulost, dnes, budoucnost)
3. [ ] S fotkou / bez fotky
4. [ ] S poznámkou / bez poznámky
5. [ ] Dark Mode přepínání
6. [ ] VoiceOver navigace
7. [ ] Landscape orientace
8. [ ] Různé velikosti písma
9. [ ] Kontrola notifikací v Nastavení
10. [ ] Kontrola eventu v Kalendáři

---

## 📞 Kam pro pomoc

### Apple dokumentace
- [SwiftData](https://developer.apple.com/documentation/swiftdata)
- [UserNotifications](https://developer.apple.com/documentation/usernotifications)
- [EventKit](https://developer.apple.com/documentation/eventkit)
- [PhotosUI](https://developer.apple.com/documentation/photokit)

### Forums
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/swiftui)

### Tools
- Xcode Instruments - pro performance profiling
- Console.app - pro system logs
- Simulator logs - `~/Library/Logs/CoreSimulator/`

---

## 🚨 Known limitations v MVP

Toto NENÍ bug, je to design decision:

1. **Notifikace nejsou batchované** - každá položka = samostatné notifikace
2. **Fotky nejsou komprimované** - může zabírat hodně místa
3. **Žádná validace data** - lze zadat datum v minulosti
4. **Žádná confirmation při cancel editace** - změny se ignorují
5. **Export do kalendáře bez custom kalendáře** - jen default
6. **Žádné undo/redo** - smazání je finální

Tyto věci přidat v post-MVP iteracích po otestování s uživateli.
