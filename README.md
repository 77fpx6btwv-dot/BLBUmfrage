# Erhebung „Erfahrungen mit dem Lernband“

Fragebögen (Schüler:innen, Eltern, Kollegium) zum Schulentwicklungstag.
Zum Ausdrucken **oder** zum anonymen Online-Ausfüllen. Die Antworten landen live in Supabase,
die Live-Auswertung steht in der Seite (Menü „Live-Auswertung“).

Dateien: `index.html` (die ganze Seite), `setup.sql` (Datenbank), `.nojekyll`.

## Einrichtung (einmalig, ca. 10 Minuten)

### 1. Datenbank anlegen
Supabase-Dashboard → **SQL Editor** → Inhalt von `setup.sql` einfügen.
Vorher `DEINE@MAIL` (Auswerter-Login) und `CODE` (Zugangscode, oder leer lassen) ersetzen → **Run**.

### 2. Auswerter-Login anlegen und Registrierung sperren
- **Authentication → Users → Add user → Create new user**: dieselbe E-Mail wie in `setup.sql`, Passwort wählen, „Auto Confirm User“ anhaken.
- **Authentication → Sign In / Providers**: „Allow new users to sign up“ **ausschalten**.
  (Zusätzlich ist der Lesezugriff in der Datenbank auf die eine E-Mail beschränkt.)

### 3. Schlüssel eintragen
**Project Settings → API Keys**: den *Publishable key* (`sb_publishable_…`, alternativ den `anon`-Key) kopieren und in `index.html`
bei `SB_KEY` einsetzen. Dieser Schlüssel ist für den öffentlichen Einsatz gedacht. **Niemals** den `secret`- oder `service_role`-Key eintragen.

### 4. Auf GitHub Pages veröffentlichen
Repository anlegen, drei Dateien hochladen (`setup.sql` kann weg), **Settings → Pages**: Branch `main`, Ordner `/ (root)`.
Erreichbar unter `https://<benutzername>.github.io/<repo-name>/`.

## So funktioniert es
- Besucher füllen einen Bogen aus und klicken unten auf „Anonym abschicken“. Gespeichert werden nur Gruppe, Datum und Antworten.
  Anonyme Besucher können nur über die Funktion `antwort_abschicken` schreiben und nichts lesen.
- Auswertung: Menü „Live-Auswertung“ → anmelden → Mittelwerte, Verteilungen und offene Antworten, filterbar nach Jahrgang.
  Gruppen oder Items mit weniger als 5 Antworten werden nicht angezeigt.
- Der Zugangscode (optional) verhindert, dass Unbefugte mit der Adresse Antworten einspeisen.
  Code ändern: in der Tabelle `einstellungen` den Wert von `zugangscode` anpassen.
- Testantworten löschen: Dashboard → Table Editor → `antworten`.

## Datenschutz, vor dem Start klären
- Region des Projekts prüfen (Project Settings → General), sie sollte in der EU liegen.
- Auftragsverarbeitungsvertrag (DPA) mit Supabase abschließen (Dashboard → Organization Settings → Legal Documents).
- Schulleitung und Datenschutzbeauftragte einbinden, Datenschutzhinweis für Schüler:innen/Eltern bereitstellen,
  ggf. Schulkonferenz/Elternvertretung informieren.
- Freitext kann Namen enthalten: Hinweis im Bogen („keine Namen nennen“) und die Antworten vertraulich behandeln.
- Nach der Auswertung die Daten löschen.
- Kostenlose Supabase-Projekte werden nach einer Woche Inaktivität pausiert. Vor dem Start kurz prüfen, ob das Projekt aktiv ist.
