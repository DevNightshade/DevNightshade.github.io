#!/usr/bin/env bash
# Synchronisiert EIN gemeinsames Datum ueber die ganze Seite:
#   - Footer/Kommentar:  "Last update [dd.mm.yy]: <dd.mm.yy>"
#   - sitemap.xml:       <lastmod>YYYY-MM-DD</lastmod>
# Stichtag = Datum des letzten Commits (HEAD). Aenderst du irgendeine Datei,
# steht das neue Datum ueberall.
# Laeuft lokal genauso wie in GitHub Actions.
set -euo pipefail
cd "$(dirname "$0")/.."

# Datum des letzten Commits; Fallback = heute (z.B. Repo ohne Commits)
DATE_SHORT="$(git log -1 --format=%cd --date='format:%d.%m.%y' 2>/dev/null || true)"
DATE_ISO="$(git log -1 --format=%cd --date='format:%Y-%m-%d' 2>/dev/null || true)"
[ -n "$DATE_SHORT" ] || DATE_SHORT="$(date +%d.%m.%y)"
[ -n "$DATE_ISO" ]   || DATE_ISO="$(date +%Y-%m-%d)"

# [^<CR>]* statt .* -> CRLF-Dateien behalten ihr \r
CR=$'\r'

# --- 1) Footer-Datum in HTML/CSS ---------------------------------------------
while IFS= read -r f; do
	grep -q 'Last update \[dd\.mm\.yy\]:' "$f" || continue
	sed -i -E "s/(Last update \[dd\.mm\.yy\]: )[^$CR]*/\1$DATE_SHORT/" "$f"
done < <(git ls-files '*.html' '*.css')

# --- 2) <lastmod> in sitemap.xml ---------------------------------------------
if [ -f sitemap.xml ]; then
	sed -i -E "s|(<lastmod>)[^<]*|\1$DATE_ISO|g" sitemap.xml
fi

echo "Alle Datumsangaben auf $DATE_SHORT ($DATE_ISO) gesetzt."
