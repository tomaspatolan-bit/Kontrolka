# Changelog

All notable changes to Kontrolka will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Plánované pro post-MVP
- OCR automatické čtení data z fotky (Vision framework)
- Batching notifikací (více položek = jedna souhrnná notifikace)
- CloudKit sync mezi zařízeními
- Widget pro iOS home screen
- Apple Watch companion app
- Šablony pro běžné položky (STK, dálniční známka, atd.)
- Opakující se události (roční pojistka)
- Komprese fotek před uložením
- Custom kadence notifikací (UI pro editaci `customReminderDays`)
- Lokalizace do angličtiny
- Filtry podle kategorie
- Vyhledávání v položkách
- Export do CSV
- Import z CSV
- Statistiky a grafy (volitelně)
- Sdílení položek s rodinou (CloudKit)

## [1.0.0] - 2026-09-04 - MVP Release

### ✨ Added

#### Core Features
- SwiftData persistence pro lokální uložení dat
- Tři hlavní obrazovky: Seznam, Přidání/Úprava, Detail
- Kategorizace položek (Vozidlo, Pojištění, Domácnost, Záruka, Doklad, Ostatní)
- Lokální notifikace s kadencí podle kategorie (30/7/1 dní nebo 7 dní)
- Export do systémového Kalendáře přes EventKit
- Připojení fotky dokladu přes PhotosUI
- Barevná indikace urgence (červená < 7d, oranžová < 30d, zelená 30d+)

#### Data Model
- `TrackedItem` model s všemi požadovanými poli
- `Category` enum s výchozími notifikačními kadencemi
- `Urgency` enum pro barevnou indikaci
- Extensions pro formátování data ("za X dní")

#### Managers
- `NotificationManager` pro správu lokálních notifikací
- `CalendarManager` pro export do kalendáře

#### Views
- `ContentView` - hlavní seznam seřazený podle `dueDate`
- `ItemRow` - komponenta pro řádek seznamu
- `AddEditItemView` - formulář pro přidání/editaci položky
- `ItemDetailView` - zobrazení detailu s akcemi
- `PhotoPreviewView` - fullscreen náhled fotky

#### UX Features
- Empty state pro prázdný seznam
- Swipe-to-delete
- Confirmation alert před smazáním
- Success/error alerting pro calendar export
- Dark Mode podpora (systémové barvy)
- VoiceOver accessibility labels
- Dynamic Type podpora

#### Documentation
- README.md s přehledem projektu
- PROJECT_STRUCTURE.md s detailní strukturou
- MVP_CHECKLIST.md s kompletním checklistem
- INFO_PLIST_GUIDE.md s instrukcemi pro oprávnění
- TROUBLESHOOTING.md s řešením běžných problémů
- API_DOCUMENTATION.md s popisem API
- Examples.swift s příklady použití

### 🎨 Design

- Použití pouze nativních SwiftUI komponent (List, NavigationStack, Form)
- Systémové fonty a barvy
- Minimalistický design s hodně prázdným prostorem
- Apple HIG compliant design
- Automatická Dark Mode podpora

### 🔐 Permissions

- NSPhotoLibraryUsageDescription pro PhotosPicker
- NSCalendarsUsageDescription pro EventKit read
- NSCalendarsWriteOnlyAccessUsageDescription pro EventKit write

### 📦 Tech Stack

- SwiftUI (iOS 17+)
- SwiftData for persistence
- UserNotifications for local notifications
- EventKit for calendar export
- PhotosUI for image picking
- Swift Concurrency (async/await)

### ⚠️ Known Limitations

- Notifikace nejsou batchované (každá položka = samostatné notifikace)
- Fotky nejsou komprimované (může zabírat hodně místa)
- Žádná validace data (lze zadat datum v minulosti)
- Export do kalendáře bez výběru custom kalendáře (jen default)
- Pouze čeština (žádná lokalizace v MVP)
- `customReminderDays` field existuje v modelu, ale UI pro editaci není implementované

### 🐛 Bug Fixes

N/A - Initial release

### 🔄 Changed

N/A - Initial release

### 🗑️ Removed

N/A - Initial release

### 🔒 Security

- Veškerá data ukládána lokálně (žádný cloud v MVP)
- Žádné síťování
- Žádné třetí strany
- Respektování systémových oprávnění

---

## Version History

- **1.0.0** (2026-09-04) - MVP Release - Initial public release

---

## Maintenance Notes

### Co sledovat po release

1. **Crash reports**
   - Missing Info.plist keys
   - SwiftData migration issues
   - Memory issues s velkými fotkami

2. **User feedback**
   - Nejpoužívanější kategorie
   - Četnost přidávání položek
   - Použití fotek vs. bez fotek
   - Využití calendar exportu

3. **Performance**
   - SwiftData fetch performance s velkým počtem položek
   - Scrolling performance na seznamu
   - Memory usage s fotkami
   - Battery impact (notifikace)

4. **iOS updates**
   - Breaking changes v SwiftData
   - Changes v UserNotifications
   - EventKit deprecations
   - SwiftUI behavior changes

### Prioritizace post-MVP features

Based on user feedback:

**High priority:**
1. Batching notifikací (nespamovat uživatele)
2. Komprese fotek (ušetřit storage)
3. OCR čtení data (snížit friction při přidávání)

**Medium priority:**
4. Šablony (rychlejší přidávání běžných položek)
5. Widget (quick glance na nadcházející lhůty)
6. Opakující se události (roční pojistky)

**Low priority:**
7. CloudKit sync (pokud users požadují multi-device)
8. Watch app (nice-to-have)
9. Export/import (backup, migrace)

**Nice-to-have:**
10. Statistiky a grafy
11. Rodinné sdílení
12. B2B features (partnerské nabídky)

---

## Contributors

- Tomáš PATOLÁN - Initial work and MVP implementation

---

## License

Proprietary - All rights reserved

---

## Support

Pro bug reports a feature requests:
- Vytvoř issue v projektu
- Nebo kontaktuj autora přímo

---

**Last updated:** 2026-09-04
