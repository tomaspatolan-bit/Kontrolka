# 🐛 Bug Report Template

**Před vytvořením bug reportu:**
- [ ] Zkontroloval jsi [TROUBLESHOOTING.md](TROUBLESHOOTING.md)?
- [ ] Zkusil jsi Clean Build Folder (Cmd+Shift+K)?
- [ ] Zkusil jsi restartovat Xcode/simulátor?

---

## Bug Information

### Popis problému
*Co se pokazilo? Buď co nejkonkrétnější.*



### Kroky k reprodukci
1. 
2. 
3. 

### Očekávané chování
*Co mělo se stát?*



### Aktuální chování
*Co se místo toho stalo?*



### Screenshots/Video
*Pokud relevantní, přilož screenshot nebo video.*



---

## Environment

- **iOS verze:** (např. 17.0)
- **Xcode verze:** (např. 15.0)
- **Zařízení:** (např. iPhone 15 Pro simulátor nebo iPhone 12 real device)
- **macOS verze:** (např. Sonoma 14.0)

---

## Dodatečné informace

### Console log
*Zkopíruj relevantní části z Xcode konzole.*

```
(paste console output here)
```

### Crash log
*Pokud app crashla, najdi crash log v Xcode (Organizer → Crashes).*

```
(paste crash log here)
```

---

## Severity

- [ ] Critical (app nefunguje vůbec)
- [ ] High (hlavní feature nefunguje)
- [ ] Medium (vedlejší feature nefunguje)
- [ ] Low (drobný UI glitch)

---

## Možné řešení (volitelné)
*Máš představu, co by mohlo problém vyřešit?*




---

# ✨ Feature Request Template

**Před vytvořením feature requestu:**
- [ ] Zkontroloval jsi [CHANGELOG.md](CHANGELOG.md#unreleased) - možná už je naplánováno?
- [ ] Přečetl jsi [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md#-mimo-rozsah-mvp--nestavěj-teď) - není to záměrně vynecháno z MVP?

---

## Feature Description

### Co chceš přidat?
*Stručný popis nové funkce.*



### Proč to chceš?
*Jaký problém to řeší? Jaký use case to pokrývá?*



### Jak by to mělo fungovat?
*Popič UX flow krok po kroku.*

1. 
2. 
3. 

---

## Mockups/Wireframes (volitelné)
*Pokud máš vizuální představu, přilož obrázky nebo náčrty.*



---

## Priority

- [ ] Must have (bez toho je app nepoužitelná)
- [ ] Should have (velmi důležité, ale ne kritické)
- [ ] Nice to have (bylo by fajn, ale ne nezbytné)
- [ ] Future (zajímavé do budoucna)

---

## Dodatečné poznámky
*Cokoli dalšího, co je relevantní.*




---

# 🔧 Development Task Template

**Pro tracking development tasků.**

---

## Task Information

### Název tasku
*Stručný název.*



### Popis
*Co konkrétně je třeba udělat?*



### Definice hotového (Definition of Done)
- [ ] Kód napsaný a otestovaný
- [ ] Unit testy přidány (pokud relevantní)
- [ ] Dokumentace aktualizovaná
- [ ] Manuálně otestováno na simulátoru
- [ ] Manuálně otestováno na reálném zařízení
- [ ] Code review proběhl
- [ ] Changelog aktualizován
- [ ] Žádné nové warningy

---

## Technical Details

### Ovlivněné soubory
- [ ] Model (TrackedItem)
- [ ] Views (ContentView, AddEditItemView, ItemDetailView)
- [ ] Managers (NotificationManager, CalendarManager)
- [ ] Helpers
- [ ] Dokumentace

### Dependencies
*Závisí tento task na jiných tascích?*



### Technické poznámky
*API notes, algoritmy, edge cases, atd.*




---

## Testing

### Test scénáře
1. 
2. 
3. 

### Edge cases k otestování
- 
- 
- 

---

## Estimate

- [ ] Small (< 2 hodiny)
- [ ] Medium (2-4 hodiny)
- [ ] Large (4-8 hodin)
- [ ] XL (> 8 hodin, zvažit rozdělit)

---

# 📋 Quick Issue Templates

## Template 1: "Nefunguje mi..."

**Co nefunguje:**

**Kroky:**
1. 
2. 

**Co se stalo:**

**Co jsem očekával:**

**Environment:** iOS X.X, Xcode X.X, [Simulátor/Zařízení]

---

## Template 2: "Chtěl bych feature..."

**Feature:**

**Proč:**

**Jak by to mělo fungovat:**

**Priorita:** [Must/Should/Nice to have]

---

## Template 3: "Našel jsem typo/chybu v dokumentaci"

**Kde:** [Název souboru]

**Co je špatně:**

**Mělo by být:**

---

# 🔍 How to Use These Templates

## For Bug Reports:

1. Copy **Bug Report Template** section
2. Fill in all relevant information
3. Attach to issue tracker / send to team
4. Label as `bug`

## For Feature Requests:

1. Copy **Feature Request Template** section
2. Describe feature and use case
3. Add mockups if possible
4. Label as `enhancement`

## For Development Tasks:

1. Copy **Development Task Template** section
2. Break down into actionable steps
3. Add to project board / task tracker
4. Assign to developer

## For Quick Issues:

1. Use appropriate Quick Issue Template
2. Fill in minimal info
3. Quick triage before creating full issue

---

# 📊 Issue Labels

Recommended labels for issue tracking:

### Type
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `question` - Question about usage
- `refactor` - Code refactoring
- `test` - Testing improvements

### Priority
- `critical` - Blocks usage, fix ASAP
- `high` - Important, fix soon
- `medium` - Normal priority
- `low` - Nice to have

### Status
- `backlog` - Not started yet
- `in-progress` - Currently working on
- `blocked` - Waiting on something
- `review` - Ready for review
- `done` - Completed

### Component
- `model` - Data model changes
- `ui` - User interface
- `notifications` - Notification system
- `calendar` - Calendar integration
- `photos` - Photo handling
- `setup` - Project setup issues

---

# 🎯 Issue Workflow

```
New Issue → Triage → Backlog → In Progress → Review → Done
                ↓
            (Close if duplicate/invalid)
```

## Triage Process:

1. **Is it valid?**
   - Check if duplicate
   - Check if it's really a bug/valid request
   - Close if not valid

2. **Severity/Priority?**
   - Label appropriately
   - Critical bugs go straight to In Progress

3. **Assign**
   - Assign to developer
   - Add to milestone/sprint

4. **Estimate**
   - Small/Medium/Large/XL
   - Break down XL issues

---

**Templates last updated:** 2026-09-04
