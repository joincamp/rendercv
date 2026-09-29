#!/usr/bin/env bash
# Render the CV: merge private contact details into the public YAML, render
# PDF + Markdown with RenderCV, convert Markdown to .docx with pandoc, then
# run ATS sanity checks on the PDF.
#
# Usage: ./render.sh   (from anywhere; run inside `nix develop` or any shell
# with uv, pandoc, and poppler's pdftotext/pdfinfo/pdffonts available)
set -euo pipefail
cd "$(dirname "$0")"

PUBLIC=Jonathan_Camp_CV.yaml
PRIVATE=private.yaml
BUILD=build
OUTPUT="$PWD/output"

if [[ ! -f "$PRIVATE" ]]; then
  echo "error: $PRIVATE not found — copy private.example.yaml and fill it in" >&2
  exit 1
fi

mkdir -p "$BUILD"

# --- Merge private.yaml into the public CV ---------------------------------
uv run --frozen python - "$PUBLIC" "$PRIVATE" "$BUILD/$PUBLIC" <<'PY'
import sys
import ruamel.yaml

yaml = ruamel.yaml.YAML()
public_path, private_path, out_path = sys.argv[1:4]

with open(public_path) as f:
    merged = yaml.load(f)
with open(private_path) as f:
    private = yaml.load(f)

def deep_merge(base, extra):
    for key, value in extra.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            deep_merge(base[key], value)
        else:
            base[key] = value

deep_merge(merged, private)
with open(out_path, "w") as f:
    yaml.dump(merged, f)
PY

# --- Render ------------------------------------------------------------------
uv run --frozen rendercv render "$BUILD/$PUBLIC" --output-folder "$OUTPUT"

PDF="$OUTPUT/Jonathan_Camp_CV.pdf"
MD="$OUTPUT/Jonathan_Camp_CV.md"
DOCX="$OUTPUT/Jonathan_Camp_CV.docx"

# --- .docx via pandoc ---------------------------------------------------------
pandoc "$MD" -f markdown -o "$DOCX"
echo "wrote $DOCX"

# --- ATS sanity checks --------------------------------------------------------
echo
echo "=== checks ==="
fail=0
check() {  # check <description> <command...>
  local desc=$1; shift
  if "$@" > /dev/null 2>&1; then
    echo "PASS  $desc"
  else
    echo "FAIL  $desc"
    fail=1
  fi
}

pages=$(pdfinfo "$PDF" | awk '/^Pages:/ {print $2}')
[[ $pages -le 2 ]] && echo "PASS  page count: $pages (<= 2)" \
                   || { echo "FAIL  page count: $pages (> 2)"; fail=1; }

TXT="$BUILD/Jonathan_Camp_CV.txt"
pdftotext -layout "$PDF" "$TXT"

check "text is selectable (extraction non-trivial)" \
  awk 'BEGIN{n=0} {n+=length($0)} END{exit !(n>2000)}' "$TXT"

for needle in "Jonathan Camp" "jon@skyreach.llc" "941" \
              "linkedin.com/in/joincamp" "Philadelphia" \
              "Citizenship: United States"; do
  check "contains: $needle" grep -qF "$needle" "$TXT"
done

# Section headers appear in the intended top-to-bottom order.
check "section order Profile>Education>Experience>Skills" \
  python3 - "$TXT" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
positions = [text.find(s) for s in ("Profile", "Education", "Experience", "Skills")]
sys.exit(0 if all(p >= 0 for p in positions) and positions == sorted(positions) else 1)
PY

# Every experience/education date survives extraction.
for date in "Nov 2024" "Sep 2019" "Sep 2018" "Aug 2016" "Jan 2013" \
            "Aug 2008" "Dec 2012" "2008" "present"; do
  check "date survives: $date" grep -qF "$date" "$TXT"
done

check "all fonts embedded" \
  bash -c "! pdffonts '$PDF' | tail -n +3 | awk '{print \$(NF-4)}' | grep -qv yes"

echo
if [[ $fail -eq 0 ]]; then
  echo "all checks passed — $PDF ($pages pages), $DOCX"
else
  echo "SOME CHECKS FAILED — inspect $TXT and $PDF" >&2
  exit 1
fi
