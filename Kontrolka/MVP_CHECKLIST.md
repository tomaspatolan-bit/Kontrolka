# MVP Checklist - Kontrolka

## ✅ Datový model

- [x] TrackedItem s všemi požadovanými poli (id, title, category, dueDate, note, photoData, customReminderDays, createdAt, updatedAt)
- [x] Category enum s rawValue lokalizovaným do češtiny
- [x] Výchozí notifikační kadence podle kategorie
- [x] Computed property `reminderDays` pro custom override

## ✅ Obrazovky

### 1. Hlavní seznam (ContentView)
- [x] Řazení podle nejbližšího dueDate (vzestupně)
- [x] Barevná tečka urgence (červená < 7d, oranžová < 30d, zelená 30d+)
- [x] Název položky + formátované datum ("za X dní")
- [x] Tlačítko "+" v navigation baru
- [x] Empty state pro prázdný seznam
- [x] Swipe-to-delete
- [x] Žádná tab bar navigace
- [x] Žádné grafy/statistiky

### 2. Přidání/Úprava (AddEditItemView)
- [x] Text field pro název (povinné)
- [x] Picker pro kategorii
- [x] Date picker pro datum
- [x] Text field pro poznámku (volitelné)
- [x] PhotosPicker pro fotku (volitelné)
- [x] Náhled fotky s možností smazání
- [x] "Uložit" / "Zrušit" v navigation baru
- [x] Validace (disabled save button pokud název prázdný)
- [x] Modal sheet prezentace

### 3. Detail (ItemDetailView)
- [x] Zobrazení všech dat položky
- [x] Zobrazení fotky (pokud existuje)
- [x] Klikatelná fotka pro fullscreen
- [x] Tlačítko "Upravit"
- [x] Tlačítko "Smazat" s potvrzením
- [x] Tlačítko "Přidat do kalendáře"
- [x] Push navigace z seznamu

## ✅ Notifikace (NotificationManager)

- [x] Požádání o oprávnění při prvním spuštění
- [x] Plánování při vytvoření položky
- [x] Replánování při úpravě položky
- [x] Zrušení při smazání položky
- [x] Správná kadence podle kategorie:
  - [x] Kritické: 30, 7, 1 den před
  - [x] Ostatní: 7 dní před
- [x] Věcný text notifikací (ne marketingový)
- [x] Lokální notifikace (ne push)
- [x] Uložení itemId do userInfo

## ✅ EventKit (CalendarManager)

- [x] Požádání o oprávnění k kalendáři
- [x] Export jako all-day event
- [x] Přidání alarmu 24h před událostí
- [x] Přidání poznámky do event notes (pokud existuje)
- [x] Error handling s uživatelskými alertami
- [x] Success alert po úspěšném exportu

## ✅ Design principy

- [x] Pouze 3 obrazovky (seznam, přidání, detail)
- [x] Nativní SwiftUI komponenty (List, NavigationStack, Form)
- [x] Systémové fonty (.body, .headline, .subheadline)
- [x] Dynamic Type podpora
- [x] Systémové barvy (automatický Dark Mode)
- [x] Hodně prázdného prostoru (spacing, padding)
- [x] Barva pouze pro urgenci (red/orange/green)
- [x] Žádné vlastní přetěžované UI prvky
- [x] Apple HIG compliant
- [x] VoiceOver accessibility labels

## ✅ Technické požadavky

- [x] SwiftUI
- [x] iOS 17+ target
- [x] SwiftData pro perzistenci
- [x] UserNotifications framework
- [x] PhotosUI framework
- [x] EventKit framework
- [x] Žádné externí závislosti
- [x] Swift Concurrency (async/await)

## ✅ Info.plist oprávnění

- [x] NSPhotoLibraryUsageDescription
- [x] NSCalendarsUsageDescription
- [x] NSCalendarsWriteOnlyAccessUsageDescription

## ❌ Vědomě VYNECHÁNO z MVP

- [ ] OCR automatické čtení data z fotky
- [ ] Účty a přihlášení
- [ ] Cloud sync (CloudKit)
- [ ] Rodinné sdílení
- [ ] B2B/partnerské funkce
- [ ] Push notifikace ze serveru
- [ ] Komplexní batching notifikací (bylo by potřeba centralizovaný scheduler)
- [ ] Tab bar navigace
- [ ] Grafy a statistiky
- [ ] Dashboard
- [ ] Lokalizace (jen čeština v MVP)
- [ ] Komprese fotek před uložením
- [ ] Widget
- [ ] Watch app
- [ ] Šablony položek
- [ ] Opakující se události

## 🧪 Testovací scénáře

### Základní flow
1. [ ] První spuštění → požádá o notifikace
2. [ ] Prázdný seznam → zobrazí empty state
3. [ ] Kliknutí na "+" → otevře AddEditItemView
4. [ ] Vyplnění formuláře a uložení
5. [ ] Seznam zobrazí novou položku s urgencí
6. [ ] Kliknutí na položku → otevře detail
7. [ ] Detail zobrazí všechna data
8. [ ] Tlačítko Upravit → otevře formulář v edit módu
9. [ ] Tlačítko Smazat → zobrazí alert a smaže
10. [ ] Swipe-to-delete na seznamu

### Fotky
1. [ ] Přidat fotku přes PhotosPicker
2. [ ] Náhled fotky v formuláři
3. [ ] Smazání fotky v formuláři
4. [ ] Fotka se zobrazí v detailu
5. [ ] Kliknutí na fotku → fullscreen preview

### Export do kalendáře
1. [ ] První export → požádá o oprávnění
2. [ ] Úspěšný export → zobrazí success alert
3. [ ] Otevřít Kalendář → ověřit event existuje
4. [ ] Event má správné datum (all-day)
5. [ ] Event má alarm 24h před

### Notifikace
1. [ ] Po vytvoření položky zkontrolovat Nastavení → Notifikace
2. [ ] Kritická kategorie → 3 naplánované notifikace (30/7/1d)
3. [ ] Ostatní kategorie → 1 naplánovaná notifikace (7d)
4. [ ] Po úpravě položky → přeplánovány notifikace
5. [ ] Po smazání položky → zrušeny notifikace

### Dark Mode
1. [ ] Přepnout do Dark Mode
2. [ ] Všechny obrazovky správně reagují
3. [ ] Barvy urgence viditelné v obou režimech
4. [ ] Fotky viditelné v obou režimech

### Accessibility
1. [ ] Zapnout VoiceOver
2. [ ] Projít všechny obrazovky
3. [ ] Ověřit labels na interaktivních prvcích
4. [ ] Zvětšit písmo v Nastavení → Dynamic Type

## 📋 Pre-release checklist

- [ ] Otestovat na reálném zařízení (ne jen simulátor)
- [ ] Otestovat všechny scénáře výše
- [ ] Zkontrolovat memory leaks (Instruments)
- [ ] Zkontrolovat performance (60fps scrolling)
- [ ] Review všech user-facing stringů (překlepy?)
- [ ] Zkontrolovat Info.plist oprávnění
- [ ] Build warnings = 0
- [ ] Archive build funguje

## 📝 Poznámky

- **Batching notifikací**: Implementace by vyžadovala centralizovaný scheduler, který analyzuje všechny položky a vytváří souhrnné notifikace. Pro MVP jsem to záměrně vynechal - jednodušší implementace, snazší debugging. Přidat v další iteraci.

- **Fotky jako Data**: V MVP ukládám přímo do SwiftData. Pro produkci zvážit file storage + jen path v databázi. Také přidat kompresi obrázků.

- **Lokalizace**: Všechny stringy jsou natvrdo v češtině. Pro mezinárodní publikum použít String catalog.

- **Custom reminder days**: Model má support pro `customReminderDays`, ale UI pro editaci tohoto pole není v MVP implementované. Přidat v další verzi jako "Pokročilé nastavení".
