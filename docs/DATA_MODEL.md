# Datový model a views

Detailní referenční popis modelu, pomocných typů, managerů a obrazovek. Pravidla
a invarianty, které je nutné dodržovat, jsou v [`CLAUDE.md`](../CLAUDE.md) v rootu.

Zdroj pravdy je vždy kód (`Kontrolka/**/*.swift`). Tento dokument ho shrnuje, ale při
rozporu platí kód — v tom případě aktualizuj tento soubor.

---

## `TrackedItem` (SwiftData `@Model`)

Soubor: `Kontrolka/Models/Item.swift`

| Pole | Typ | Poznámka |
|------|-----|----------|
| `id` | `UUID` | Unikátní identifikátor. Používá se jako klíč notifikací (`userInfo["itemId"]`). |
| `title` | `String` | Název položky (např. „STK - Škoda Octavia"). Povinné, nesmí být prázdné. |
| `category` | `Category` | Kategorie z enumu níže. Určuje výchozí kadenci notifikací. |
| `dueDate` | `Date` | Datum vypršení lhůty. |
| `note` | `String?` | Volitelná poznámka. |
| `photoData` | `Data?` | Volitelná fotka dokladu uložená přímo v SwiftData (bez komprese). |
| `customReminderDays` | `[Int]?` | Vlastní kadence notifikací; přepíše default kategorie. UI pro editaci zatím není. |
| `createdAt` | `Date` | Datum vytvoření. |
| `updatedAt` | `Date` | Datum poslední úpravy. Ručně aktualizované při každé editaci. |

**Computed / extension properties:**

- `reminderDays: [Int]` — vrací `customReminderDays ?? category.defaultReminderDays`.
- `urgency: Urgency` — spočítá se z počtu zbývajících dní (viz níže). Extension v `TrackedItemHelpers.swift`.
- `dueDateFormatted: String` — lokalizovaný český text („Vyprší zítra", „Vyprší za X dní",
  „Vypršelo před X dny", nebo konkrétní datum pro > 30 dní). Extension v `TrackedItemHelpers.swift`.

---

## `Category` (enum, `String` rawValue)

Soubor: `Kontrolka/Models/Item.swift`. RawValue je český název zobrazovaný v UI.

| Case | RawValue | Výchozí kadence (`defaultReminderDays`) |
|------|----------|------------------------------------------|
| `.vehicle` | „Vozidlo" | `[30, 7, 1]` |
| `.insurance` | „Pojištění" | `[30, 7, 1]` |
| `.homeMaintenance` | „Domácnost" | `[30, 7, 1]` |
| `.warranty` | „Záruka" | `[7]` |
| `.document` | „Doklad" | `[7]` |
| `.other` | „Ostatní" | `[7]` |

Kritické kategorie (`.vehicle`, `.insurance`, `.homeMaintenance`) mají trojitou kadenci
30/7/1 dní; ostatní jen 7 dní předem.

---

## `Urgency` (enum)

Soubor: `Kontrolka/Models/TrackedItemHelpers.swift`. Počítá se z `daysRemaining` v `TrackedItem.urgency`.

| Case | Podmínka | `color` | `textColor` |
|------|----------|---------|-------------|
| `.critical` | `< 7` dní | `.urgencyCriticalFill` | `.urgencyCriticalText` |
| `.warning` | `< 30` dní | `.urgencyWarningFill` | `.urgencyWarningText` |
| `.normal` | `30+` dní | `.urgencyNormalFill` | `.urgencyNormalText` |

Barvy jsou brand barvy definované v `BrandColors.swift`. `color` je pro tečky/ikony,
`textColor` má vyšší kontrast pro text.

---

## Managery

### `NotificationManager`

Soubor: `Kontrolka/Managers/NotificationManager.swift`. `@MainActor`, singleton (`.shared`), lokální notifikace.

- `requestAuthorization() async -> Bool` — požádá o oprávnění (`.alert`, `.badge`, `.sound`).
- `scheduleNotifications(for:) async` — **nejdřív zavolá `cancelNotifications(for:)`**, pak naplánuje
  novou sadu podle `item.reminderDays`. Přeskočí termíny v minulosti. Identifikátor notifikace je
  `"\(id)-\(daysBeforeDue)"`, `userInfo["itemId"]` = `id.uuidString`.
- `cancelNotifications(for:) async` — najde pending requesty podle `userInfo["itemId"]` a odstraní je.
- `cancelAllNotifications()` — zruší úplně všechno (debug/reset).

**Text notifikací** je věcný, ne marketingový:
- 1 den předem: title „Zítra vyprší lhůta", body = `title`.
- Ostatní: title = `title`, body „Vyprší za X dní".

### `CalendarManager`

Soubor: `Kontrolka/Managers/CalendarManager.swift`. `@MainActor`, singleton (`.shared`), EventKit.

- `requestAccess() async -> Bool` — oprávnění ke kalendáři (write-only).
- `exportToCalendar(item:) async throws` — vytvoří all-day event v defaultním kalendáři,
  alarm 24 h předem, poznámku z `note` pokud existuje. **Opakované volání vytváří duplicity** (bez deduplikace).

---

## Views

Navigační shell je `MainTabView` (`App/`): nativní `TabView` se **3 taby** — **Domů** (`DomuView`,
dashboard), **Přehled** (`ContentView`, seznam) a **Profil** (`ProfileView`). Akční **„+"** je oddělený
trailing slot přes `Tab(role: .search)`; nepřepíná obsah, jen otevře confirmation dialog (přidat ručně /
vyfotit doklad) → `AddEditItemView`. Uvnitř tabů je navigace `NavigationStack` (push) + sheety.
Onboarding (`OnboardingView`) běží před shellem a v posledním kroku nechá uživatele přidat první položku.

### `DomuView` (tab Domů)
Soubor: `Kontrolka/Views/Home/DomuView.swift`. Dashboard s uvítací kartou a widgety kategorií
(vozidlo jako featured + mřížka ostatních). Prázdný stav = pozvánka: mřížka kategorií s ilustracemi,
ťuknutí otevře `AddEditItemView` s předvybranou kategorií. Push do `CategoryDetailView`.

### `ContentView` (tab Přehled)
Soubor: `Kontrolka/Views/Home/ContentView.swift`. Seznam všech termínů.
- `@Query(sort: \TrackedItem.dueDate, order: .forward)` — řazení podle nejbližšího termínu.
- Souhrnná karta (`PrehledSummaryCard`) + karty položek (`TrackedItemCardView`) s tečkou urgence.
- Prázdný seznam → `ContentUnavailableView`. Swipe-to-delete (nejdřív zruší notifikace, pak smaže).
- Push do `ItemDetailView`. Přidávání jde přes „+" v tab baru, ne z této obrazovky.

### `AddEditItemView`
Soubor: `Kontrolka/Views/Items/AddEditItemView.swift`. Přidání i editace (modal sheet).
- Parametry: `modelContext`, volitelně `initialCategory` (předvybraná kategorie), `initialPhotoData`
  (fotka z kamery), `itemToEdit` (`nil` = přidání) a `onSaved` (callback po uložení — když je nastaven,
  převezme řízení místo `dismiss()`; využívá ho onboarding).
- Pole: název (povinné), kategorie (Picker), datum (DatePicker), poznámka, fotka (`PhotosPicker`).
- Náhled fotky s možností smazání. „Uložit" je disabled, dokud je název prázdný.

### `ItemDetailView`
Soubor: `Kontrolka/Views/Items/ItemDetailView.swift`. Detail položky.
- Parametry: `item`, `modelContext`.
- Zobrazí všechna data + fotku (klik → fullscreen `PhotoPreviewView`).
- Akce: Upravit (otevře `AddEditItemView` v edit módu), Smazat (s confirmation alertem),
  Přidat do kalendáře (EventKit s error/success alerty).

**Struktura zdrojáků** (`Kontrolka/`): `App/` (KontrolkaApp, MainTabView), `Models/` (Item,
TrackedItemHelpers, Profile), `Managers/` (Notification, Calendar), `DesignSystem/` (BrandColors,
Motion), `Views/{Onboarding,Home,Items,Profile}/` a `Support/` (Examples). Další views: DomuView
(Home), OnboardingView/OnboardingShowcase, ProfileEditView, CategoryDetailView, TrackedItemCardView,
CameraCaptureView (vše ve `Views/…`).

---

## Limity a omezení

- **SwiftData:** fotky se ukládají jako `Data` bez komprese; není optimalizováno pro tisíce položek.
- **Notifikace:** iOS limit 64 naplánovaných notifikací na aplikaci. Bez centrálního batchingu se
  při hodně položkách limit vyčerpá (viz seznam „mimo MVP" v `CLAUDE.md`).
- **Kalendář:** vyžaduje defaultní kalendář; opakovaný export vytváří duplicity.
