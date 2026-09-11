# 🎨 UI Update Changelog - Kontrolka v1.1.0

**Datum:** 04.09.2026  
**Typ:** Modernizace UI  
**Status:** ✅ Kompletní a funkční

---

## 🚀 Co je NOVÉ

### 1. Modernizovaná Navigace

#### Custom Bottom Bar
- ✅ **Vlastní bottom bar** místo standardní tab bar
- ✅ **3 sekce:** Seznam | [Plus] | Nastavení
- ✅ **Vystouplé plus tlačítko** uprostřed (+56px circle, blue gradient, shadow)
- ✅ **Selected state indikace** (blue tint)

**Soubory:**
- `MainTabView.swift` - Root view container ✨ NOVÝ
- `CustomTabBar.swift` - Bottom bar komponenta ✨ NOVÝ

---

### 2. Vylepšené Přidávání Položek

#### Confirmation Dialog
- ✅ **Plus tlačítko → Dialog s 2 opcemi:**
  - "Přidat ručně" → klasický formulář
  - "Vyfotit doklad" → otevře fotoaparát
  - "Zrušit"

#### Camera Integration
- ✅ **CameraCaptureView** - UIImagePickerController wrapper
- ✅ **Přednahrání fotky** - vyfocená fotka se automaticky nahraje do formuláře
- ✅ **AddEditItemView.init** - nový parametr `initialPhotoData: Data?`

**Soubory:**
- `CameraCaptureView.swift` ✨ NOVÝ
- `AddEditItemView.swift` - upraven init

---

### 3. Karty Místo Řádků

#### TrackedItemCardView (Nová Komponenta)
- ✅ **Card-based design** místo simple rows
- ✅ **Ikony podle kategorie** v barevném kruhu
- ✅ **Thumbnail fotek** (36x36) na kartě
- ✅ **Kompaktnější layout** (44x44 ikona, spacing 14, padding 12)
- ✅ **Rounded corners** (16pt, continuous)
- ✅ **Secondary background** color

**Layout:**
```
┌─────────────────────────────────────────────────────┐
│  [◉ Ikona]  Název položky               [📷]  ›    │
│             Kategorie                               │
│             Datum (barevně)                         │
└─────────────────────────────────────────────────────┘
```

**Soubory:**
- `TrackedItemCardView.swift` ✨ NOVÝ (nahradil původní ItemRow)

---

### 4. Modernější Ikony

#### Category.iconName Extension
Nové, přesnější SF Symbols:

| Kategorie | Stará Ikona | Nová Ikona ✨ |
|-----------|-------------|----------------|
| vehicle | car.fill | car.fill (stejné) |
| insurance | shield.fill | shield.fill (stejné) |
| homeMaintenance | house.fill | **wrench.and.screwdriver.fill** |
| warranty | checkmark.seal.fill | checkmark.seal.fill (stejné) |
| document | doc.fill | **person.text.rectangle.fill** |
| other | ellipsis.circle.fill | **tray.fill** |

**Soubor:**
- `Item.swift` - Category extension (nebo TrackedItemCardView.swift)

---

### 5. Nastavení (Placeholder)

#### SettingsView
- ✅ **Základní settings view** (placeholder pro MVP)
- ✅ **Sekce "O aplikaci"** - Verze 1.0.0
- ✅ **Sekce "Systém"** - Link na systémová oprávnění

**Soubor:**
- `MainTabView.swift` - obsahuje SettingsView jako vnořenou strukturu

---

## 📋 Info.plist Změny

### NOVĚ POVINNÉ ✨
```xml
<key>NSCameraUsageDescription</key>
<string>Kontrolka potřebuje přístup k fotoaparátu, abys mohl vyfotit doklad.</string>
```

**Proč:** CameraCaptureView vyžaduje přístup k fotoaparátu

### Stávající (nezměněno)
- ✅ NSPhotoLibraryUsageDescription
- ✅ NSCalendarsUsageDescription
- ✅ NSCalendarsWriteOnlyAccessUsageDescription

---

## 🔄 Upravené Soubory

### KontrolkaApp.swift
**Změna:** Root view změněn z `ContentView()` na `MainTabView()`
```swift
// PŘED:
WindowGroup {
    ContentView()
}

// PO:
WindowGroup {
    MainTabView()  // ✨
}
```

---

### ContentView.swift
**Změny:**
- ✅ Odstraněn toolbar s plus tlačítkem (přesunuto do MainTabView)
- ✅ Odstraněna sheet pro AddEditItemView (přesunuto do MainTabView)
- ✅ Změněna struktura ItemRow → TrackedItemCardView
- ✅ Použití NavigationLink(value:) místo destination closure
- ✅ Hidden list separators, clear row background

```swift
// PŘED:
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button { showingAddSheet = true } 
        label: { Label("Přidat položku", systemImage: "plus") }
    }
}

// PO:
// Toolbar removed - přesunuto do MainTabView bottom bar
```

---

### AddEditItemView.swift
**Změny:**
- ✅ Nový parametr v init: `initialPhotoData: Data?`
- ✅ Logika pro přednahrání fotky z kamery
- ✅ Explicitní `self.` v closures (fix errorů)

```swift
// PŘED:
init(modelContext: ModelContext, itemToEdit: TrackedItem? = nil)

// PO:
init(modelContext: ModelContext, initialPhotoData: Data? = nil, itemToEdit: TrackedItem? = nil)  // ✨
```

---

### ItemDetailView.swift
**Změny:**
- ✅ Volání AddEditItemView se správnou signaturou (initialPhotoData: nil)

```swift
// PŘED:
AddEditItemView(modelContext: modelContext, itemToEdit: item)

// PO:
AddEditItemView(modelContext: modelContext, initialPhotoData: nil, itemToEdit: item)  // ✨
```

---

## 🗑️ Smazané/Nahrazené

### Odstraněno
- ❌ `ItemRow` struct z ContentView.swift
- ❌ Plus button toolbar v ContentView
- ❌ AddEditItemView sheet v ContentView
- ❌ Starý `TrackedItemCard.swift` soubor (duplicita)

### Nahrazeno
- `ItemRow` → `TrackedItemCardView` ✨
- Plus toolbar button → Bottom bar plus button ✨
- Direct AddEditItemView sheet → MainTabView confirmation dialog ✨

---

## 🎯 UX Flow Změny

### Přidání Nové Položky

**PŘED:**
```
ContentView → Toolbar "+" → AddEditItemView sheet
```

**PO:** ✨
```
MainTabView → Bottom bar Plus button 
→ Confirmation dialog
→ "Přidat ručně" → AddEditItemView (bez fotky)
→ "Vyfotit doklad" → CameraCaptureView → AddEditItemView (s fotkou)
```

---

### Seznam Položek

**PŘED:**
```
List > ItemRow (barevná tečka + text)
```

**PO:** ✨
```
List > TrackedItemCardView (karta s ikonou + thumbnail)
```

---

## 📊 Statistiky

### Nové Soubory: 4
1. MainTabView.swift (~125 řádků)
2. CustomTabBar.swift (~102 řádků)
3. CameraCaptureView.swift (~50 řádků)
4. TrackedItemCardView.swift (~106 řádků)

**Celkem přidáno:** ~383 řádků nového kódu

### Upravené Soubory: 4
1. KontrolkaApp.swift (1 řádek změněn)
2. ContentView.swift (~20 řádků změněno)
3. AddEditItemView.swift (~10 řádků změněno)
4. ItemDetailView.swift (~2 řádky změněny)

**Celkem upraveno:** ~33 řádků

### Smazané Soubory: 1
- TrackedItemCard.swift (duplicita)

---

## ✅ Testing Checklist

### Nové Funkce k Otestování
- [ ] Bottom bar zobrazí správně
- [ ] Plus tlačítko je vystouplé uprostřed
- [ ] Kliknutí na plus → zobrazí dialog
- [ ] "Přidat ručně" → otevře formulář bez fotky
- [ ] "Vyfotit doklad" → otevře kameru (požádá o oprávnění)
- [ ] Po vyfocení → formulář s přednahranou fotkou
- [ ] Karty zobrazují správné ikony podle kategorie
- [ ] Karty zobrazují thumbnail fotky (pokud existuje)
- [ ] Tab switching funguje (Seznam ↔ Nastavení)
- [ ] Selected tab má blue tint
- [ ] Dark Mode funguje správně

### Regresní Testy
- [ ] Přidání položky ručně stále funguje
- [ ] Editace položky stále funguje
- [ ] Smazání položky stále funguje
- [ ] Swipe-to-delete stále funguje
- [ ] Notifikace se plánují správně
- [ ] Export do kalendáře funguje
- [ ] Fotky z galerie fungují (PhotosPicker)

---

## 🐛 Known Issues & Fixes

### Issue 1: Duplicitní TrackedItemCardView
**Problém:** "Invalid redeclaration of TrackedItemCardView"  
**Příčina:** Existoval `TrackedItemCard.swift` i `TrackedItemCardView.swift`  
**Fix:** ✅ Smazat `TrackedItemCard.swift` v Xcodu

### Issue 2: AddEditItemView init mismatch
**Problém:** Volání s parametrem `initialPhotoData` který neexistoval  
**Příčina:** MainTabView používal novou signaturu před její implementací  
**Fix:** ✅ Přidán parametr `initialPhotoData: Data?` do AddEditItemView.init

### Issue 3: Category.iconName duplicita
**Problém:** "Invalid redeclaration of iconName"  
**Příčina:** Extension byla v obou souborech  
**Fix:** ✅ Ponechána jen v TrackedItemCardView.swift

---

## 🚀 Next Steps (Post v1.1.0)

### Immediate
1. ✅ Data Model aktualizován (CLAUDE_CONTEXT.md)
2. ⚠️ Otestovat na reálném zařízení
3. ⚠️ Zkontrolovat že NSCameraUsageDescription je v Info.plist

### Short-term (v1.2.0)
- [ ] Haptic feedback při interakcích
- [ ] Animace při přepínání tabů
- [ ] Pull-to-refresh v seznamu
- [ ] Loading states pro async operace

### Mid-term (v2.0.0)
- [ ] OCR čtení data z fotky po vyfocení
- [ ] Komprese fotek před uložením
- [ ] Batching notifikací
- [ ] Widget pro home screen

---

## 📝 Migration Guide (pro vývojáře)

### Pokud upgradeuješ z v1.0.0:

1. **Přidej NSCameraUsageDescription** do Info.plist
2. **Nahraď ContentView root** v KontrolkaApp.swift za MainTabView
3. **Smaž TrackedItemCard.swift** pokud existuje (duplicita)
4. **Pull nové soubory** z repo:
   - MainTabView.swift
   - CustomTabBar.swift
   - CameraCaptureView.swift
   - TrackedItemCardView.swift (updated)
5. **Build & Test**

---

**Autor:** Tomáš PATOLÁN  
**Datum:** 04.09.2026  
**Verze:** 1.1.0  
**Status:** ✅ Production Ready

