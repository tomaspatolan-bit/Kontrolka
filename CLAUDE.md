# CLAUDE.md

Pravidla a invarianty pro práci na aplikaci **Kontrolka**. Tady jsou jen pravidla,
ne popis jednotlivých views a polí — ten je v [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md).

## Tech stack

- Nativní iOS app, **SwiftUI + SwiftData**, Swift Concurrency (`async`/`await`).
- Deployment target **iOS 26.5** (`IPHONEOS_DEPLOYMENT_TARGET` v projektu). Můžeš používat
  moderní API včetně Liquid Glass (`.glassEffect`). Frameworky: UserNotifications, PhotosUI, EventKit.
- **Žádné externí závislosti** — žádné SPM/CocoaPods/Carthage. Vše řeš nativními API.
- UI je celé **v češtině** (žádná lokalizace v MVP — viz níže).

## Konvence

- Model: `TrackedItem` (`@Model`), kategorie enum `Category` s českým `rawValue`.
- Kód píš ve stylu okolních souborů; UI stringy jsou napevno česky.
- Managery jsou `@MainActor` singletony (`NotificationManager.shared`, `CalendarManager.shared`).
- Async operace z UI spouštěj přes `Task { ... }`, ne přímo z akce tlačítka.
- Barvy jen pro urgenci (`Urgency` → brand barvy v `BrandColors.swift`); jinak systémové barvy
  a fonty, Dynamic Type, Dark Mode, VoiceOver labely na interaktivních prvcích.
- Uvnitř tabů je navigace `NavigationStack` (push) + sheety.
- **Vlastní bottom bar** (`MainTabView.swift`): Liquid Glass kapsle se 3 taby (**Domů**, **Přehled**,
  **Profil**) roztažená přes šířku, plus **oddělené akční „+"** (`AddButton`) na stejném řádku vpravo.
  Není to nativní `TabView` (ten neumí akční „+" oddělený vpravo se správným zarovnáním) — layout
  řídíme sami v `safeAreaInset(edge: .bottom)`, materiál zůstává nativní Liquid Glass. Přepínání tabů
  jde přes `AppTab` + `currentTab`. „+" otevírá confirmation dialog (ručně / vyfotit).

## Klíčová pravidla (invarianty)

Tyto tři musí platit **vždy**, jinak se rozjede stav notifikací nebo `updatedAt`:

1. **Po každé změně položky (vytvoření i editaci) zavolej
   `NotificationManager.shared.scheduleNotifications(for: item)`.**
   Metoda si sama zruší staré notifikace položky a naplánuje novou sadu podle `reminderDays`.

2. **Před smazáním položky zruš její notifikace:**
   `await NotificationManager.shared.cancelNotifications(for: item)` a teprve pak
   `modelContext.delete(item)`.

3. **Při každé editaci nastav `item.updatedAt = Date()`** předtím, než přeplánuješ notifikace.

Doplňkově: `title` nesmí být prázdný (validace ukládání); `id` je stabilní klíč notifikací —
neměň ho. Export do kalendáře může selhat a při opakování vytváří duplicity → drž error/success alerty.

## Vědomě MIMO MVP — neimplementuj bez zadání

Následující je **záměrně vynecháno**. Nepřidávej to spontánně; pokud to zadání vyžaduje, nejdřív se ptej.

- OCR / čtení data z fotky (Vision)
- Účty, přihlášení, cloud sync (CloudKit)
- Rodinné sdílení
- B2B / partnerské / lead-gen funkce
- Push notifikace ze serveru (jen lokální notifikace)
- Batching notifikací / centralizovaný scheduler (pozor na iOS limit 64 notifikací)
- Grafy, statistiky, dashboardy
- Lokalizace (jen čeština)
- Komprese fotek před uložením
- Widget, Apple Watch app
- Šablony položek
- Opakující se události
- UI pro editaci `customReminderDays` (model to podporuje, UI ne)

## Build a CI

- **Na tomto stroji (Windows) není Xcode — nelze buildovat ani spouštět lokálně.**
- Build ověřuje **GitHub Actions na macOS runneru** (`.github/workflows/ios.yml`):
  `xcodebuild build` pro `Kontrolka` scheme, iOS Simulator, bez code signingu.
- Postup po změnách: **commitni, pushni a počkej na CI.** Výsledek ověř podle běhu Actions
  (např. `gh run watch`), ne lokálně. Kdyby CI hlásil chyby nebo něco není jasné, ptej se.
