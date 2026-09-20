# Architektura Kontrolky (mapa projektu)

Rychlá orientace pro budoucí úpravy: **kde co je** a **kde co měnit**. Pravidla a invarianty
jsou v [`CLAUDE.md`](../CLAUDE.md), detailní popis modelu/obrazovek v
[`docs/DATA_MODEL.md`](DATA_MODEL.md). Při rozporu platí kód → pak aktualizuj tyhle dokumenty.

Tech stack: nativní iOS (SwiftUI + SwiftData, Swift Concurrency), deployment target **iOS 26.5**,
Liquid Glass, žádné externí závislosti, UI česky. Build jen přes CI (GitHub Actions).

---

## Struktura složek (`Kontrolka/`)

```
App/
  KontrolkaApp.swift      @main; ModelContainer (schema TrackedItem + TrackedThing);
                          migrace didMigrateThingsV1; přepíná Onboarding ↔ MainTabView
  MainTabView.swift       nativní TabView (Domů/Přehled/Profil) + "+" jako Tab(role:.search);
                          confirmation dialog + add sheet; ProfileView/ProfileSummaryCard/ProfileRow
Models/
  Item.swift              TrackedItem (@Model) + enum Category (usesThings, defaultReminderDays,
                          subcategorySuggestions)
  TrackedThing.swift      TrackedThing (@Model): věc s cascade relací items:[TrackedItem], nearestItem
  TrackedItemHelpers.swift  Urgency enum + Category.illustrationName/widgetTitle +
                          TrackedItem.urgency/shortDeadline/compactDeadline/dueDateFormatted
  Profile.swift           Profil uživatele (@AppStorage helpers, věk, formátování)
Managers/
  NotificationManager.swift  @MainActor singleton; plánování + prioritizace na limit 64
  CalendarManager.swift      @MainActor singleton; EventKit export
DesignSystem/
  BrandColors.swift       brand barvy (urgency + surfaces), BrandGradientBackground
  Motion.swift            animace: appearReveal, PressableCardStyle, zoomTransition/zoomSource, Haptics
Views/
  Home/
    DomuView.swift          dashboard: uvítací karta + widgety kategorií; navigační destinace
    DashboardScrollers.swift WrapScroller + obsah karet (VehicleThingContent, SmallThingContent,
                          SmallItemContent, AddContent, CategoryArt)
    ContentView.swift       tab Přehled: plochý seznam všech položek
  Items/
    AddEditItemView.swift   adaptivní přidání/editace (nová věc / termín k věci / plochá položka)
    ThingDetailView.swift   detail věci (termíny, přidat termín, smazat věc) + ThingRowCard
    CategoryDetailView.swift detail kategorie (asset → seznam věcí, ploché → seznam položek)
    ItemDetailView.swift    detail položky + PhotoPreviewView
    TrackedItemCardView.swift  karta položky do seznamu (Category.iconName)
    CameraCaptureView.swift camera pro "vyfotit doklad"
  Onboarding/
    OnboardingView.swift    4 kroky: uvítání → hodnota/notifikace → profil → přidej první věc
    OnboardingShowcase.swift animovaný dashboard náhled ve 2. kroku
  Profile/
    ProfileEditView.swift   editace profilu
Support/
  Examples.swift          příklady použití API (není v produkční cestě)
```

---

## Datový model (stručně)

Dvě úrovně u **asset kategorií** (`Category.usesThings == true`: Vozidlo, Domácnost, Mazlíček):

```
TrackedThing (věc, např. "Škoda Octavia")
  └─ items: [TrackedItem]   (termíny: STK, gumy, rozvody…)   cascade delete
```

**Ploché kategorie** (Pojištění, Záruka, Doklad, Ostatní) mají `TrackedItem` přímo, `thing == nil`.
Detail polí a kadencí notifikací je v [`DATA_MODEL.md`](DATA_MODEL.md).

---

## Navigace

- Root (`KontrolkaApp`): `hasCompletedOnboarding` (@AppStorage) → `OnboardingView` nebo `MainTabView`.
- `MainTabView`: nativní `TabView` se 3 taby + „+" jako `Tab(role:.search)` (výběr `.add` obsah nepřepne,
  jen otevře confirmation dialog → `AddEditItemView`).
- **Navigační destinace jsou v rootu `DomuView`** (jeden `NavigationStack`):
  `Category` → `CategoryDetailView`, `TrackedThing` → `ThingDetailView`, `TrackedItem` → `ItemDetailView`.
  `ContentView` (Přehled) má vlastní stack s destinací `TrackedItem` → `ItemDetailView`.
- Přidání se otevírá jako `.sheet` (z „+" v baru, z karet dashboardu, z detailů, z onboardingu).

---

## Klíčové flows (kde se co děje)

### Přidání / editace — `AddEditItemView`
Adaptivní podle režimu:
- **Nová věc** (`itemToEdit==nil`, `category.usesThings`): název věci + multi-chip termínů, každý s vlastním
  datem → vytvoří `TrackedThing` + jednu `TrackedItem` na termín.
- **Termín k existující věci** (`existingThing != nil`): jen multi-chip termínů → položky pod tu věc.
- **Plochá položka / editace**: klasický formulář (název, datum, podkategorie chips, poznámka, foto).
- Vstupy: „+" v baru (`MainTabView`), karty/dlaždice na Domů, „Přidat termín" v `ThingDetailView`,
  „Přidat" v `CategoryDetailView`, onboarding, „Upravit" v `ItemDetailView`.

### Dashboard widgety — `DomuView` + `DashboardScrollers.swift`
- Widget = jeden rámeček; uvnitř `WrapScroller` stránkuje obsah (spacing 0, `containerRelativeFrame`,
  `scrollTargetBehavior(.paging)`), tečky uvnitř (poslední = „+" = „přidat" stránka). „Nekonečný" wrap
  přes velký virtuální rozsah (stránka = index % (počet+1)).
- **Karusel jen když kategorie NENÍ prázdná.** Prázdná kategorie → default widget s ilustrací
  (`VehicleWidget`/`SmallCategoryWidget`), klepnutím přidáš.
- Karusel má: **vozidlo** (velká karta: název nahoře + 2 sloupce), **mazlíček/dům** (přes věci),
  **doklad** (přes ploché položky). **Ostatní** = bez karuselu (`SmallCategoryWidget` → `CategoryDetailView`).

### Notifikace — `NotificationManager` (INVARIANT, viz CLAUDE.md)
Po každé změně položky `scheduleNotifications(for:)`, před smazáním `cancelNotifications(for:)`.
`enforceGlobalLimit()` drží globálně ~60 nejbližších (iOS strop 64) — vzdálené ořezává.

### Kalendář — `CalendarManager`
`ItemDetailView` → „Přidat do kalendáře" (EventKit, error/success alerty; opakování = duplicity).

### Onboarding — `OnboardingView`
Uvítání → hodnota/notifikace → profil → **přidej první věc** (`AddEditItemView` s `onSaved` dokončí flow).

### Migrace věcí — `KontrolkaApp.migrateOrphanItemsIntoThings()`
Jednorázově (`didMigrateThingsV1`) obalí staré ploché položky asset kategorií do vlastní věci.

---

## Kde měnit co

| Chci změnit… | Soubor(y) / typ |
|---|---|
| pole položky / kadenci notifikací / kategorie | `Models/Item.swift` (`TrackedItem`, `Category`) |
| co je „věc" / vztah věc↔termíny | `Models/TrackedThing.swift` |
| návrhy podkategorií (chips) | `Category.subcategorySuggestions` v `Models/Item.swift` |
| která kategorie má hierarchii věcí | `Category.usesThings` v `Models/Item.swift` |
| barvy urgence / formát termínu | `Models/TrackedItemHelpers.swift`, `DesignSystem/BrandColors.swift` |
| formulář přidání/editace | `Views/Items/AddEditItemView.swift` |
| vzhled/chování dashboard widgetů a scrolleru | `Views/Home/DashboardScrollers.swift`, `Views/Home/DomuView.swift` |
| detail věci / detail položky / detail kategorie | `Views/Items/ThingDetailView.swift` / `ItemDetailView.swift` / `CategoryDetailView.swift` |
| seznam Přehled | `Views/Home/ContentView.swift` |
| taby / „+" / navigační shell | `App/MainTabView.swift` |
| plánování / limit notifikací | `Managers/NotificationManager.swift` |
| export do kalendáře | `Managers/CalendarManager.swift` |
| onboarding kroky | `Views/Onboarding/OnboardingView.swift` |
| model container / migrace / root přepínač | `App/KontrolkaApp.swift` |

---

## Invarianty a hranice

- **Invarianty** (notifikace, `updatedAt`, validace, custom bar/„+") → [`CLAUDE.md`](../CLAUDE.md).
- **Vědomě mimo MVP / odloženo** → sekce v [`CLAUDE.md`](../CLAUDE.md) + poznámka o iOS 27 (vizuální test).
- **Build**: lokálně nejde (Windows); ověřuje CI (`.github/workflows/ios.yml`).
</content>
