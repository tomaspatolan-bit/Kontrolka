# 🚀 Getting Started - 5 Minute Setup

**Cíl:** Spustit aplikaci Kontrolka na simulátoru nebo zařízení za 5 minut.

---

## ✅ Co potřebuješ

- ✅ Mac s macOS Sonoma nebo novější
- ✅ Xcode 15.0 nebo novější
- ✅ Projekt Kontrolka (máš ho otevřený)

---

## 📋 3 Kroky k úspěchu

### Krok 1: Otevři projekt (30 sekund)

1. V Xcodu, pokud není projekt otevřený:
   - File → Open
   - Najdi `Kontrolka.xcodeproj`
   - Klikni Open

2. Počkej, až Xcode indexuje soubory (progress bar nahoře)

✅ **Ověření:** V levém panelu (Navigator) vidíš soubory projektu

---

### Krok 2: Přidej oprávnění do Info.plist (2 minuty)

**⚠️ DŮLEŽITÉ: Bez tohoto kroku aplikace crashne!**

#### Metoda A: Přes Xcode UI (doporučeno)

1. V levém panelu klikni na **Kontrolka** (modrá ikona projektu nahoře)
2. V hlavním panelu vyber target **Kontrolka** (pod PROJECT)
3. Klikni na záložku **Info**
4. Najdi sekci **Custom iOS Target Properties**
5. Klikni na **+** (plus) u libovolného řádku

**Přidej tyto 3 klíče:**

**První klíč:**
- Key: `Privacy - Photo Library Usage Description`
- Type: String (default)
- Value: `Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.`

**Druhý klíč:**
- Key: `Privacy - Calendars Usage Description`
- Type: String
- Value: `Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.`

**Třetí klíč:**
- Key: `Privacy - Calendars Write Only Access Usage Description`
- Type: String
- Value: `Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.`

✅ **Ověření:** Vidíš všechny 3 klíče v seznamu Custom iOS Target Properties

---

#### Metoda B: Přes Info.plist soubor (alternativa)

Pokud máš v projektu soubor `Info.plist`:

1. Otevři ho v Xcodu
2. Right-click → Open As → Source Code
3. Přidej před `</dict>`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.</string>

<key>NSCalendarsUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>

<key>NSCalendarsWriteOnlyAccessUsageDescription</key>
<string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>
```

✅ **Ověření:** XML je validní (žádné červené errory)

---

### Krok 3: Build & Run (1 minuta)

1. **Vyber destination:**
   - Nahoře vedle názvu projektu vyber simulátor (např. "iPhone 15 Pro")
   - Nebo připoj reálné zařízení a vyber ho

2. **Spusť aplikaci:**
   - Klikni na ▶️ (Play) tlačítko nahoře vlevo
   - Nebo stiskni **Cmd+R**

3. **Počkej na build:**
   - První build trvá ~30 sekund
   - Uvidíš progress bar nahoře
   - Po dokončení se spustí simulátor/app

4. **Povolit notifikace:**
   - Při prvním spuštění se objeví dialog
   - Klikni **Allow**

✅ **Ověření:** Aplikace běží, vidíš prázdný seznam s textem "Žádné položky"

---

## 🎉 Hotovo! Co dál?

### Vyzkoušej základní funkce (2 minuty)

1. **Přidat položku:**
   - Klikni na **+** (plus) vpravo nahoře
   - Vyplň název: "Test STK"
   - Vyber kategorii: "Vozidlo"
   - Nastav datum: za týden od dnes
   - Klikni **Uložit**

2. **Prohlédnout detail:**
   - Klikni na položku v seznamu
   - Uvidíš všechny detaily
   - Vrať se Back tlačítkem

3. **Smazat položku:**
   - V seznamu swipe vlevo na položce
   - Klikni **Delete**
   - Položka zmizí

✅ **Funguje vše?** Aplikace je připravena k použití!

---

## 🐛 Něco nefunguje?

### App crashne při spuštění

**Nejčastější příčina:** Chybí Info.plist oprávnění

**Řešení:**
1. Zavři aplikaci
2. Vrať se na Krok 2 výše
3. Ověř, že jsi přidal všechny 3 klíče
4. Build & Run znovu

**Stále crashne?**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md#1-app-crashne-při-otevření-photospicker)

---

### Build failed / červené errory

**Možné příčiny:**
- Chybí soubory
- Nesprávný target
- Xcode má starou cache

**Řešení:**
1. **Clean Build Folder:** Product → Clean Build Folder (Cmd+Shift+K)
2. **Restart Xcode**
3. **Build znovu:** Cmd+R

**Stále errory?**
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

### Simulátor se nespustí

**Řešení:**
1. Zavři simulátor (Cmd+Q)
2. Xcode → Window → Devices and Simulators
3. Zkontroluj, že máš nějaký simulátor nainstalovaný
4. Zkus jiný simulátor (např. iPhone 14 místo 15)

---

### Aplikace je strašně pomalá

**Příčina:** Debug build na simulátoru je pomalejší

**Řešení:**
- Normální pro vývoj
- Pro rychlejší testing: Testuj na reálném zařízení
- Nebo: Product → Scheme → Edit Scheme → Run → Build Configuration → Release

---

## 📚 Další kroky

### Naučit se víc o aplikaci

**Dokumentace:**
- 📖 [README.md](README.md) - Přehled aplikace
- 🎯 [DELIVERY_SUMMARY.md](DELIVERY_SUMMARY.md) - Kompletní přehled
- 📁 [FILE_INDEX.md](FILE_INDEX.md) - Index všech souborů

**Kód:**
- Začni s [ContentView.swift](ContentView.swift) - Hlavní obrazovka
- Pak [ItemDetailView.swift](ItemDetailView.swift) - Detail
- Nakonec [AddEditItemView.swift](AddEditItemView.swift) - Formulář

### Otestovat všechny funkce

→ [MVP_CHECKLIST.md](MVP_CHECKLIST.md#-testovací-scénáře)

**Rychlý test (5 min):**
1. Přidat položku s fotkou
2. Editovat položku
3. Přidat do kalendáře (otevři Kalendář app a ověř)
4. Zkontrolovat notifikace (Nastavení → Notifikace → Kontrolka)
5. Smazat položku

### Začít vyvíjet

**API reference:**
→ [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

**Příklady kódu:**
→ [Examples.swift](Examples.swift)

**Best practices:**
→ [API_DOCUMENTATION.md - Best Practices](API_DOCUMENTATION.md#best-practices)

---

## 🎓 Tipy pro začátečníky

### Xcode Shortcuts

| Shortcut | Akce |
|----------|------|
| Cmd+R | Build & Run |
| Cmd+. | Stop |
| Cmd+B | Build (bez spuštění) |
| Cmd+Shift+K | Clean Build Folder |
| Cmd+Shift+O | Open Quickly (najdi soubor) |
| Cmd+Shift+F | Find in Project |
| Cmd+/ | Zakomentovat/odkomentovat |

### SwiftUI Live Preview

1. Otevři `ContentView.swift`
2. Napravo klikni na **Resume** (nebo Cmd+Option+P)
3. Uvidíš live preview bez spouštění simulátoru
4. Při editaci kódu se preview automaticky aktualizuje

**Poznámka:** Preview někdy crashuje, to je normální - klikni Resume znovu

### Console Logs

Během vývoje uvidíš v konzoli debug zprávy:

```
📦 SwiftData obsahuje 0 položek:
🔔 Naplánované notifikace: 0
```

Tyto zprávy pomáhají s debuggingem. Najdi je v:
- Xcode → View → Debug Area → Activate Console (Cmd+Shift+C)

### Breakpoints

Pro debugging:
1. Klikni na číslo řádku v kódu (objeví se modrá šipka)
2. Spusť app (Cmd+R)
3. Když kód doběhne k breakpointu, app se zastaví
4. Můžeš prozkoumat hodnoty proměnných

---

## 🎯 Checklist úspěšného setupu

Po dokončení všech kroků zkontroluj:

- [ ] Projekt se otevřel v Xcodu bez errorů
- [ ] Přidal jsi všechny 3 Info.plist klíče
- [ ] Build proběhl úspěšně (zelený checkmark)
- [ ] App se spustila na simulátoru/zařízení
- [ ] Vidíš prázdný seznam s "Žádné položky"
- [ ] Můžeš přidat novou položku
- [ ] Můžeš otevřít detail
- [ ] Můžeš smazat položku

**Všechny checkmarky?** 🎉 **Jsi připravený začít!**

---

## 💬 Pomoc a podpora

### Dokumentace

- **Nejdřív zkus:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Pak se podívej:** [FILE_INDEX.md](FILE_INDEX.md) → Quick Find

### Časté problémy a řešení

| Problém | Řešení |
|---------|--------|
| App crashne | [TROUBLESHOOTING.md](TROUBLESHOOTING.md#1-app-crashne-při-otevření-photospicker) |
| Build failed | Clean Build Folder (Cmd+Shift+K) |
| Notifikace nefungují | [TROUBLESHOOTING.md](TROUBLESHOOTING.md#4-notifikace-se-neplánují) |
| Fotka se nezobrazuje | [TROUBLESHOOTING.md](TROUBLESHOOTING.md#5-fotka-se-nezobrazuje-v-detailu) |
| SwiftData nefunguje | [TROUBLESHOOTING.md](TROUBLESHOOTING.md#3-swiftdata-nefunguje--data-se-neukládají) |

### Další zdroje

- **Apple Developer Docs:** https://developer.apple.com/documentation/
- **SwiftUI Tutorials:** https://developer.apple.com/tutorials/swiftui
- **Stack Overflow:** https://stackoverflow.com/questions/tagged/swiftui

---

## 🎊 Gratuluji!

Úspěšně jsi nastavil a spustil aplikaci Kontrolka!

**Co dál:**
1. ✅ Projdi [MVP_CHECKLIST.md](MVP_CHECKLIST.md) a otestuj všechny funkce
2. 📚 Přečti si [DELIVERY_SUMMARY.md](DELIVERY_SUMMARY.md) pro kompletní přehled
3. 💻 Začni zkoumat kód a dělej změny
4. 🚀 Build amazing features!

**Hodně štěstí!** 🍀

---

**Setup Time:** ~5 minut  
**Difficulty:** ⭐⭐☆☆☆ (Easy)  
**Next:** [README.md](README.md) nebo [DELIVERY_SUMMARY.md](DELIVERY_SUMMARY.md)
