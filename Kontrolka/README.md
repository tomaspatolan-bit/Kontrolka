
Pracuješ na existující iOS aplikaci Kontrolka (SwiftUI, iOS 17+, čeština). Uprav pouze CustomTabBar (a případně MainTabView, pokud si to vynutí layout) — funkčnost, routování mezi taby ani confirmation dialog na plus tlačítku se nemění, jde čistě o vizuál a animace.

Současný stav baru:

Pozadí capsule: .ultraThinMaterial + .background.opacity(0.5) — aproximace skla přes Material, ne nativní Liquid Glass.
Aktivní tab: skleněný kruh 50×50 (.ultraThinMaterial + modrý tint 0.15), přechod přes .spring(response: 0.3, dampingFraction: 0.7) na opacity/scale.
Plus tlačítko: 60×60 kruh, ruční gradient [Color.blue, Color.blue.opacity(0.8)] + .ultraThinMaterial overlay 0.3, offset -40pt nad barem, centrované přes .overlay(alignment: .top).
Padding: horizontal 16pt, top/bottom cca 10pt.
1. Nahraď aproximaci skla nativním Liquid Glass (iOS 26)
Pozadí capsule: .glassEffect(.regular, in: Capsule()) místo .ultraThinMaterial + opacity.
Aktivní tab indikátor: .glassEffect(.regular.tint(.blue.opacity(0.15))) místo ručního kruhu s Material fill.
Capsuli, aktivní indikátor i plus tlačítko dej do jednoho GlassEffectContainer — to je smysl Liquid Glass, ne tři oddělené blur vrstvy vedle sebe, ale jeden materiál, který se opticky spojuje.
Přechod aktivního tabu přepiš z ručního spring/opacity na .glassEffectID(_:in:) se sdíleným @Namespace — dostaneš nativní plynulé "přelití" skla mezi taby při přepnutí, ne fade/scale, co je tam teď.
Plus tlačítko: .glassEffect(.regular.tint(Color.blue).interactive()) místo ručního gradientu + material overlay. .interactive() dá nativní stisk/odlesk při tapu zdarma, bez vlastní animace.
Target zůstává iOS 17+: všechno výš zabal do if #available(iOS 26, *) { … } else { … }, kde else větev je prostě současná .ultraThinMaterial varianta beze změny — nepiš dvě implementace od nuly, jen zachovej dnešní vzhled jako fallback pro starší iOS.
accessibilityReduceTransparency fallback (spadne na .regularMaterial / pevné pozadí) nech beze změny, jen ověř, že funguje i pro nové glassEffect větve.
2. Plus tlačítko: vycentrovat a zvětšit
Zvětši z 60×60 na cca 68–72×68–72pt.
Ověř, že centrování je vůči celé capsuli, ne jen vůči jedné její polovině — se 4 taby (Seznam, Kalendář, Nové, Nastavení) musí být přesně 2 vlevo a 2 vpravo od tlačítka.
Uprav offset proporčně k novému rozměru (cca -44 až -46pt místo -40pt), ať tlačítko dál vizuálně sedí na horní hraně baru stejně jako teď.
3. Zmenši celkovou výšku baru
Sniž vertikální padding capsule (cíl cca top 6–8pt / bottom 6–8pt místo současných ~10pt).
Zmenši skleněný "focus" kruh za aktivní ikonou z 50×50 na cca 42–44×44pt.
Cílová výška samotné capsule bez vyčnívajícího plus tlačítka: cca 56–60pt.
Text labely (Seznam/Kalendář/Nové/Nastavení) nech, jen prověř mezeru mezi ikonou a textem — pokud je tam víc prostoru, než je nutné, zmenši.

Nezasahuj do: confirmation dialogu, routování mezi taby, ikon jednotlivých tabů ani do CalendarTabView/ItemDetailView.

Po dokončení stručně shrň, co se změnilo, a uveď, jestli sis u nějakého konkrétního čísla (padding, velikost) dovolil/a se odchýlit od zadání a proč.
