# Info.plist Konfigurace

## 🔐 Povinná oprávnění pro MVP

Aplikace Kontrolka vyžaduje tři oprávnění pro plnou funkčnost:

### 1. Přístup k fotogalerii (PhotosUI)
**Klíč:** `NSPhotoLibraryUsageDescription`  
**Hodnota:** `Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.`

**Proč:** Pro výběr fotky dokladu v AddEditItemView pomocí PhotosPicker.

### 2. Přístup ke kalendáři (čtení)
**Klíč:** `NSCalendarsUsageDescription`  
**Hodnota:** `Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.`

**Proč:** Pro export položky do systémového Kalendáře.

### 3. Přístup ke kalendáři (zápis)
**Klíč:** `NSCalendarsWriteOnlyAccessUsageDescription`  
**Hodnota:** `Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.`

**Proč:** Pro vytvoření nové události v kalendáři.

---

## 📝 Jak přidat v Xcode

### Metoda 1: Přes Xcode UI (doporučeno)

1. Otevři projekt v Xcode
2. V levém panelu vyber projekt **Kontrolka**
3. Vyber target **Kontrolka**
4. Přejdi na záložku **Info**
5. Rozklikni **Custom iOS Target Properties**
6. Klikni na **+** pro přidání nového klíče
7. Vyber z nabídky nebo zadej ručně:
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Calendars Usage Description`
   - `Privacy - Calendars Write Only Access Usage Description`
8. Do sloupce **Value** zadej české popisky výše

### Metoda 2: Přímo v Info.plist souboru

Pokud máš v projektu soubor `Info.plist`, otevři ho a přidej:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Tvoje existující klíče -->
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.</string>
    
    <key>NSCalendarsUsageDescription</key>
    <string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>
    
    <key>NSCalendarsWriteOnlyAccessUsageDescription</key>
    <string>Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.</string>
</dict>
</plist>
```

---

## ⚠️ Co se stane, když chybí oprávnění?

### Chybí NSPhotoLibraryUsageDescription
- **Symptom:** App crashne při pokusu otevřít PhotosPicker
- **Error:** `This app has crashed because it attempted to access privacy-sensitive data without a usage description`
- **Řešení:** Přidej klíč do Info.plist

### Chybí NSCalendarsUsageDescription
- **Symptom:** App crashne při pokusu o export do kalendáře
- **Error:** `This app has crashed because it attempted to access privacy-sensitive data without a usage description`
- **Řešení:** Přidej klíč do Info.plist

---

## ✅ Jak ověřit, že oprávnění fungují

### 1. PhotosUI oprávnění
```swift
// Když uživatel klikne na "Přidat fotku dokladu" v AddEditItemView
// iOS automaticky zobrazí alert s textem z NSPhotoLibraryUsageDescription
// Po schválení se otevře PhotosPicker
```

### 2. Calendar oprávnění
```swift
// Když uživatel klikne na "Přidat do kalendáře" v ItemDetailView
// CalendarManager požádá o oprávnění
// iOS zobrazí alert s textem z NSCalendarsUsageDescription
// Po schválení se vytvoří event v kalendáři
```

---

## 🔍 Debug oprávnění

### Zkontrolovat aktuální stav oprávnění

```swift
import Photos
import EventKit

// Fotogalerie
let photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
print("Photo status: \(photoStatus)")
// .notDetermined = ještě se neptal
// .restricted = omezeno (rodičovská kontrola)
// .denied = uživatel zamítl
// .authorized = povoleno
// .limited = omezený přístup (iOS 14+)

// Kalendář
let eventStore = EKEventStore()
let calendarStatus = EKEventStore.authorizationStatus(for: .event)
print("Calendar status: \(calendarStatus)")
// .notDetermined = ještě se neptal
// .restricted = omezeno
// .denied = zamítnuto
// .authorized = povoleno
// .fullAccess = plný přístup (iOS 17+)
// .writeOnly = pouze zápis (iOS 17+)
```

### Resetovat oprávnění pro testování

1. Zavři aplikaci
2. Jdi do **Nastavení** → **Obecné** → **Přenést nebo resetovat iPhone** → **Obnovit** → **Obnovit umístění a soukromí**
3. Nebo pro konkrétní app: **Nastavení** → **Kontrolka** → Změň oprávnění

---

## 📱 Testování na zařízení

### Simulátor
- Fotogalerie: Funguje s omezeným obsahem
- Kalendář: Funguje, vytvoří se v simulátorové databázi

### Reálné zařízení (doporučeno)
- Fotogalerie: Plná funkčnost s tvými reálnými fotkami
- Kalendář: Vytvoří event ve tvém skutečném kalendáři

⚠️ **Pozor:** Export do kalendáře na reálném zařízení vytvoří skutečný event! Testuj s dummy daty.

---

## 🌐 Lokalizace oprávnění (budoucí rozšíření)

Pro mezinárodní publikum přidej lokalizované verze popisků:

1. V Xcode: **File** → **New** → **File** → **Strings File**
2. Pojmenuj ho `InfoPlist.strings`
3. V pravém panelu klikni **Localize...**
4. Přidej jazyky (English, atd.)

**InfoPlist.strings (cs):**
```
"NSPhotoLibraryUsageDescription" = "Kontrolka potřebuje přístup k fotkám, abys mohl přidat fotku dokladu.";
"NSCalendarsUsageDescription" = "Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.";
"NSCalendarsWriteOnlyAccessUsageDescription" = "Kontrolka potřebuje přístup ke kalendáři, abys mohl exportovat lhůty.";
```

**InfoPlist.strings (en):**
```
"NSPhotoLibraryUsageDescription" = "Kontrolka needs access to your photos to attach document pictures.";
"NSCalendarsUsageDescription" = "Kontrolka needs calendar access to export your deadlines.";
"NSCalendarsWriteOnlyAccessUsageDescription" = "Kontrolka needs calendar access to export your deadlines.";
```

---

## 🚫 Oprávnění, která NEPOTŘEBUJEME v MVP

- ❌ `NSLocationWhenInUseUsageDescription` - žádná lokace
- ❌ `NSCameraUsageDescription` - žádné focení přes kameru (jen výběr z galerie)
- ❌ `NSContactsUsageDescription` - žádné kontakty
- ❌ `NSMicrophoneUsageDescription` - žádný mikrofon
- ❌ `NSRemindersUsageDescription` - žádné připomínky (používáme notifikace)
- ❌ `NSHealthShareUsageDescription` - žádné zdravotní údaje

---

## 📋 Checklist před build

- [ ] Všechny 3 klíče přidány do Info.plist
- [ ] České popisky jsou srozumitelné a stručné
- [ ] Build prochází bez warningů
- [ ] Otestováno na simulátoru
- [ ] Otestováno na reálném zařízení
- [ ] Oprávnění se správně zobrazují při prvním použití
- [ ] App nechybí po zamítnutí oprávnění
