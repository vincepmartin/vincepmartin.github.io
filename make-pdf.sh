#!/usr/bin/env bash
# Regenerate the resume PDF from resume_print.html using headless Chrome/Chromium.
# Usage: ./make-pdf.sh [output.pdf]   (default: vince_martin_resume_latest.pdf)
# Set CHROME=/path/to/chrome to override browser detection.
set -euo pipefail

cd "$(dirname "$0")"
OUT="${1:-vince_martin_resume_latest.pdf}"

find_chrome() {
  if [ -n "${CHROME:-}" ]; then echo "$CHROME"; return; fi
  local c
  for c in google-chrome google-chrome-stable chromium chromium-browser; do
    if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
  done
  # Playwright's bundled Chromium, if present
  c=$(ls -d "$HOME"/.cache/ms-playwright/chromium-*/chrome-linux*/chrome 2>/dev/null | sort | tail -1 || true)
  if [ -n "$c" ]; then echo "$c"; return; fi
  echo "No Chrome/Chromium found. Install one or set CHROME=/path/to/chrome." >&2
  exit 1
}

CHROME_BIN="$(find_chrome)"
"$CHROME_BIN" --headless --no-sandbox --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="$(realpath -m "$OUT")" "file://$PWD/resume_print.html"

if command -v pdfinfo >/dev/null 2>&1; then
  pdfinfo "$OUT" | grep Pages
fi
echo "Wrote $OUT"
