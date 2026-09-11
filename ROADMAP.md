# Roadmapa — Kontrolka

Přehled stavu a plán směrem k testovatelnému buildu. Pravidla a invarianty jsou
v [`CLAUDE.md`](CLAUDE.md), datový model ve [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md).
Zdroj pravdy pro design je Figma.

## ✅ Hotovo

- **Onboarding** — 3 kroky (Uvítání → Hodnota/Notifikace → Profil), nativní
  rekonstrukce Figma Motion (zoom do dashboardu + odkrytí detailu), žádost
  o notifikace na 2. kroku, uložení profilu do `@AppStorage`. Gate na první spuštění.
- **Navigace** — vlastní bottom bar (Liquid Glass materiál) s vyvýšeným „+"
  uprostřed; taby Domů · Kalendář · [+] · Přehled · Profil.
- **Domů (dashboard)** — logo, uvítací/souhrnná karta, featured widget Vozidlo,
  mřížka kategorií; data z reálných `TrackedItem`.
- **Klikací Domů → detail kategorie** — hero ilustrace + shrnutí + seznam termínů
  kategorie + „Přidat termín" (předvyplní kategorii). Termín → detail položky.
- **Přehled** — SummaryCard + „VŠECHNY TERMÍNY" + karty položek.
- **Profil** — základ (souhrnná karta + O aplikaci / Systém).
- **Kalendář** — měsíční mřížka s tečkami urgence.
- **App ikona** — vyexportovaná z Figmy.
- **Barvy (light)** — sladěné s Figma tokeny; přidána kategorie **Mazlíček**.
- **Motion/mikroanimace** — zoom přechod widget→detail (iOS 18+), press efekt
  karet, animace přidání/smazání termínu.

## 🎨 Tvoje TODO (design) — ať se nebijeme

- **Ikony** — dodáš finální sadu; nahradíme SF Symbol placeholdery a sjednotíme
  (pozor na duplicity — teď je `iconName` na dvou místech: kategorie vs. karta).
- **Kontrast** — projít místa se slabým kontrastem (zejména text na kartách/gradientu).
- **Dark mode** — doděláme společně (viz níže).

## 🛣️ Cesta k testu (priorita)

1. **Napojit profil naostro** — jméno + datum narození z onboardingu do
   GreetingCard a Profilu (výpočet věku) + obrazovka **Profil-Edit**.
2. **Sladit zbývající obrazovky s Figmou** — Nová položka, detail položky,
   prázdné stavy („Nothing added Homepage").
3. **Přístupnost + kontrast** — VoiceOver labely, Dynamic Type, kontrastní pass.
4. **Dark mode** — dořešit dark hodnoty tokenů (`BrandColors.swift`) a gradientů;
   dnes je dark jen prozatímní/placeholder.
5. **Ikony kategorií** — po dodání nahradit placeholdery a odstranit duplicitu.
6. **Doladit motion** — přechody mezi taby, jemné entrance animace dashboardu,
   haptika u „+".
7. **Notifikace + oprávnění** — ověřit na zařízení (iOS limit 64, věcnost textů,
   re-plánování při editaci, zrušení při smazání).
8. **TestFlight příprava** — signing/bundle id, texty v Info.plist, varianty app
   ikony (light/dark/tinted), číslo verze, build warnings = 0.
9. **Testovací scénáře** — proklikání celého flow + edge cases (prázdno, hodně
   položek, dlouhé názvy, položka po termínu).

## 💡 Nápady na motion (nad rámec hotového)

- Staggered entrance widgetů na Domů při prvním zobrazení.
- Přechod mezi taby (jemný cross-fade / posun obsahu).
- Haptická odezva u „+" a u dokončení onboardingu.
- Animovaná tečka/urgence při změně stavu položky.

## 🧊 Vědomě odložené / zjednodušené

- **Model „věc/asset"** (Rodinný dům, Škoda Octavia s atributy) — detail je zatím
  seznam položek kategorie, ne konkrétní věc.
- **Inter font** — zatím systémový SF.
- **Batching notifikací**, OCR, cloud sync, rodinné sdílení a další — viz sekce
  „mimo MVP" v `CLAUDE.md`.

## ❓ Otevřené otázky

- Profil: stačí jméno + datum narození, nebo i avatar/foto?
- Detail kategorie: má hero zůstat ilustrace + shrnutí, nebo později přejít na
  model „věc"?
- Dark mode: dodáš hodnoty z Figmy, nebo je mám odvodit z light palety?
