# Ikony a ilustrace — co potřebuju

Seznam pro dodání assetů. Nejdřív formát, pak **co už máme** (ať se neposílá
znovu), pak co potřebuju, a nakonec volitelné. Až mi je pošleš, přidám je do
`Assets.xcassets` (imageset s „Preserve Vector Data") a napojím na kód
(`Category.illustrationName` / `iconName`), takže nahradí placeholdery bez duplicit.

## Formát (ať to jde vložit bez úprav)

- **SVG, path-based** — bez `<style>` bloků, filtrů, masek, bitmap a pokud možno
  bez gradientů. Takové `actool` (kompilace asset katalogu) spolehlivě zpracuje.
- **Glyph ikony:** čtvercový `viewBox`, ideálně **24×24**, **jednobarevné**
  (barvu nastavuju v kódu — posílej v jedné barvě, klidně černé).
- **Ilustrace:** line-art ve stejném stylu jako stávající (Auto/Dům/…), šířka ~100–150.
- **Název souboru = přesně navržený název** níže — ať nevznikají duplicity. Víc
  variant → `nazev-alt`.

## ✅ Už máme — NEposílat znovu

- Wordmark logo — `Logo`
- App ikona — `AppIcon` (+ značka `AppMark`)
- Ilustrace kategorií:
  `IllustrationCar` (auto), `IllustrationPet` (pes), `IllustrationHouse` (dům),
  `IllustrationDocuments` (doklady), `IllustrationOther` (ostatní),
  `IllustrationPerson` (osoba/figurína)

## 🔴 Potřebuju (priorita)

### Ilustrace (line-art, styl jako stávající)

| Účel | Navržený název | Poznámka |
|---|---|---|
| Empty state „Zatím nic nesleduješ" | `IllustrationEmpty` | teď placeholder (SF `sparkles`) |
| Kategorie **Pojištění** | `IllustrationInsurance` | kategorie zatím bez ilustrace |
| Kategorie **Záruka** | `IllustrationWarranty` | kategorie zatím bez ilustrace |

### Ilustrace typů věcí (per-typ, ne jen per-kategorie)

Aby konkrétní věc měla ilustraci podle svého typu (kočka vs. pes, motorka vs. auto), ne jen
podle kategorie. Vyžaduje i malou úpravu v kódu: pole „typ" na `TrackedThing` + mapování na
ilustraci — udělám, až budou assety. Výchozí (auto/pes) už máme.

| Kategorie | Typ | Navržený název | Priorita |
|---|---|---|---|
| Mazlíček | Pes | `IllustrationPet` | ✅ máme (výchozí) |
| Mazlíček | Kočka | `IllustrationPetCat` | 🔴 hlavní |
| Vozidlo | Auto | `IllustrationCar` | ✅ máme (výchozí) |
| Vozidlo | Motorka | `IllustrationCarMotorcycle` | 🔴 |
| Vozidlo | Skútr | `IllustrationCarScooter` | 🟡 |
| Vozidlo | Sporťák | `IllustrationCarSports` | 🟡 |

### Glyph ikony kategorií (24×24, jednobarevné)

Nahradí SF Symboly v kartách položek a v detailu. Figma stránka **„Ikony"** je už
má (Shield, Wrench, Car, Check, IdCard, Tray, Health, Paw) — stačí vyexportovat jako SVG.

| Kategorie | Navržený název | Motiv |
|---|---|---|
| Vozidlo | `icon-vehicle` | auto |
| Pojištění | `icon-insurance` | štít |
| Domácnost | `icon-home` | dům / klíč / nářadí |
| Mazlíček | `icon-pet` | tlapka |
| Záruka | `icon-warranty` | pečeť / fajfka |
| Doklady | `icon-document` | občanka |
| Ostatní | `icon-other` | krabice / mřížka |

## 🟡 Volitelné / nice-to-have

- **Tab bar ikony** (Domů, Kalendář, Přehled, Profil) — teď SF Symbols
  (`house`, `calendar`, `list.bullet`, `person`); klidně nech.
- **App ikona — dark + tinted varianta** (iOS 18) — pro dark mode.
- **Summary-Indicator** — malý badge vpravo nahoře na widgetu; teď nativní tečka.
- **Urgency „zóny" na autě** (STK / dálniční známka / pneu / servis) na featured
  Vozidlo widgetu — teď nativní tečky; kdybys chtěl rozsvítitelné zóny jako ve Figmě.
- **Avatar placeholder** — teď iniciála / `person.fill`.

## ℹ️ Teď SF Symbols (funkční, měnit netřeba)

Drobné UI ikony beru ze SF Symbols — dodávat je nemusíš. Kdybys chtěl vlastní:
`plus`, `chevron.left/right/down`, `pencil`, `trash`, `photo`, `calendar`,
`calendar.badge.plus`, `person.fill`, `house(.fill)`, `list.bullet`,
`lock.shield`, `info.circle`, `sparkles`, a kategorie fallbacky `car.fill`,
`shield.fill`, `wrench.and.screwdriver.fill`, `pawprint.fill`,
`checkmark.seal.fill`, `person.text.rectangle.fill`, `tray.fill`.

## Jak dodat

- Ideálně **SVG soubory**, nebo **odkaz na Figma frame/komponentu** (vyexportuju sám).
- Klidně pošli víc, než je v seznamu — čím víc motivů/variant, tím líp; přebytek
  jednoduše nezapojím.
