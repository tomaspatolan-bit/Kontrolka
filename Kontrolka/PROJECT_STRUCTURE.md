# Kontrolka - MVP Struktura projektu

## 📁 Struktura souborů

```
Kontrolka/
├── KontrolkaApp.swift              # Hlavní vstupní bod aplikace
├── Models/
│   ├── Item.swift                  # TrackedItem model (přejmenovaný z Item.swift)
│   └── TrackedItemHelpers.swift    # Extension pro urgenci a formátování
├── Views/
│   ├── ContentView.swift           # Hlavní seznam položek
│   ├── AddEditItemView.swift       # Přidání/úprava položky (modal)
│   └── ItemDetailView.swift        # Detail položky
├── Managers/
│   ├── NotificationManager.swift   # Správa lokálních notifikací
│   └── CalendarManager.swift       # Export do kalendáře přes EventKit
└── Info.plist                      # Konfigurace (viz níže)
```

## ⚙️ Potřebné změny v Info.plist

Do `Info.plist` (nebo v Xcode projekt settings pod Info) přidej tyto klíče:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.</string>

<key>NSCalendarsUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>

<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>
```

**Alternativně v Xcode:**
1. Target → Info → Custom iOS Target Properties
2. Přidej klíče:
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Calendars Usage Description`
   - `Privacy - Calendars Write Only Access Usage Description`

## 🚀 Implementované funkce

### ✅ SwiftData Model (TrackedItem)
- Všechna požadovaná pole: id, title, category, dueDate, note, photoData, customReminderDays, createdAt, updatedAt
- Enum Category s výchozími kadencemi notifikací
- Computed property `reminderDays` pro logiku

### ✅ Tři obrazovky
1. **ContentView** (hlavní seznam)
   - Řazení podle nejbližšího dueDate
   - Barevná tečka urgence (červená/oranžová/zelená)
   - Formátování "za X dní" nebo konkrétní datum
   - Empty state
   - Swipe-to-delete
   
2. **AddEditItemView** (přidání/úprava)
   - Form s všemi poli
   - PhotosPicker pro výběr fotky
   - Náhled fotky s možností smazání
   - Validace (tlačítko Uložit disabled pokud je název prázdný)
   
3. **ItemDetailView** (detail)
   - Zobrazení všech dat včetně fotky
   - Tlačítko Upravit (otevře AddEditItemView)
   - Tlačítko Smazat (s potvrzením)
   - Tlačítko Přidat do kalendáře (s EventKit)
   - Klikatelná fotka pro fullscreen náhled

### ✅ Notifikace (NotificationManager)
- Automatické plánování při vytvoření/úpravě položky
- Správná kadence podle kategorie:
  - Kritické (.vehicle, .insurance, .homeMaintenance): 30, 7, 1 den před
  - Ostatní (.warranty, .document, .other): 7 dní před
- Zrušení notifikací při smazání položky
- Text notifikací: věcný, ne marketingový

### ✅ Export do Kalendáře (CalendarManager)
- Požádá o oprávnění přes EventKit
- Vytvoří all-day event na datum vypršení
- Přidá alarm 24h před událostí
- Error handling s uživatelsky přívětivými alertami

### ✅ Design principy
- Pouze nativní SwiftUI komponenty (List, NavigationStack, Form)
- Systémové fonty s podporou Dynamic Type
- Respektování Dark Mode (systémové barvy)
- Hodně prázdného prostoru (spacing, padding)
- Tlumené barvy kromě urgence (červená/oranžová/zelená)
- VoiceOver accessibility labels
- Apple HIG compliant design

## 🧪 Testování

**Základní flow:**
1. Spusť aplikaci → požádá o oprávnění k notifikacím
2. Klikni na "+" → otevře se AddEditItemView
3. Vyplň název, vyber kategorii, nastav datum
4. (Volitelně) Přidej poznámku a fotku
5. Uložit → položka se objeví v seznamu
6. Klikni na položku → otevře se detail
7. V detailu zkus:
   - Přidat do kalendáře (požádá o oprávnění)
   - Upravit položku
   - Smazat položku (potvrzení)

**Kontrola urgence:**
- Vytvoř položku s datem < 7 dní → červená tečka
- Vytvoř položku s datem < 30 dní → oranžová tečka
- Vytvoř položku s datem > 30 dní → zelená tečka

**Kontrola notifikací:**
- Po vytvoření položky zkontroluj v Nastavení → Notifikace → Kontrolka → Naplánované notifikace
- Měly by tam být notifikace podle kategorie (30/7/1 dní nebo 7 dní před)

## 📝 Co NENÍ v MVP (podle specifikace)

❌ OCR automatické čtení data z fotky  
❌ Účty, přihlášení, cloud sync  
❌ Rodinné sdílení  
❌ B2B funkce, lead-gen, doporučení partnerů  
❌ Push notifikace ze serveru  
❌ Batching notifikací (implementace by vyžadovala komplexnější logiku s analyzováním všech položek najednou)  
❌ Tab bar navigace (jen NavigationStack)  
❌ Grafy, statistiky, dashboardy  

## 🐛 Poznámky k implementaci

1. **Batching notifikací** - V MVP je základní implementace bez batchingu. Pro plný batching by bylo potřeba:
   - Při plánování notifikací analyzovat všechny položky
   - Pokud více položek vyprší ve stejném období, vytvořit jednu souhrnnou notifikaci
   - To vyžaduje centralizovaný scheduler, který přeplánuje všechny notifikace při každé změně
   - Přidal bych to v další iteraci po otestování MVP

2. **Fotky** - Ukládám jako Data přímo v SwiftData. Pro produkci zvážit:
   - Ukládat jen file path/URL
   - Komprimovat obrázky před uložením
   - Limit na velikost fotky

3. **Accessibility** - Základní podpora je implementovaná (labels, VoiceOver), ale pro produkci:
   - Otestovat s VoiceOver zapnutým
   - Přidat více accessibility traits
   - Otestovat s větší velikostí písma (Dynamic Type)

4. **Lokalizace** - Všechny texty jsou v češtině natvrdo. Pro širší publikum:
   - Použít String katalogy
   - Lokalizovat do angličtiny minimálně

## 🎯 Další kroky po MVP

Po otestování MVP s reálnými uživateli zvážit:
- OCR pro automatické načítání dat z fotek (Vision framework)
- CloudKit sync mezi zařízeními
- Widget pro iOS home screen
- Apple Watch companion app
- Šablony pro běžné položky (STK, dálniční známka atd.)
- Opakující se položky (roční pojistka)
- Notifikační batching (viz poznámka výše)
