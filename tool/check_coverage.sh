#!/usr/bin/env bash
set -euo pipefail

flutter test --coverage

DOMAIN_THRESHOLD=80
PRESENTATION_THRESHOLD=60
AUDIO_THRESHOLD=80

fail=0

check_coverage() {
  local pattern="$1"
  local threshold="$2"
  local label="$3"

  if ! lcov --summary coverage/lcov.info 2>/dev/null | grep -q "lines"; then
    echo "lcov not found or no coverage data — skipping $label"
    return
  fi

  local pct
  pct=$(lcov --extract coverage/lcov.info "*${pattern}*" -o /tmp/filtered.info 2>/dev/null \
    && lcov --summary /tmp/filtered.info 2>&1 \
    | grep "lines" \
    | grep -oP '[0-9]+\.[0-9]+(?=%)' \
    | head -1)

  if [ -z "$pct" ]; then
    echo "No coverage data for $label (pattern: $pattern)"
    return
  fi

  echo "$label: ${pct}%  (threshold: ${threshold}%)"

  if (( $(echo "$pct < $threshold" | bc -l) )); then
    echo "  FAIL — below threshold"
    fail=1
  else
    echo "  PASS"
  fi
}

check_coverage "lib/features/*/domain/" "$DOMAIN_THRESHOLD" "Domain layer"
check_coverage "lib/shared/audio/"      "$AUDIO_THRESHOLD"  "Shared audio"
check_coverage "lib/features/*/presentation/" "$PRESENTATION_THRESHOLD" "Presentation layer"

if [ "$fail" -eq 1 ]; then
  echo ""
  echo "Coverage check FAILED — one or more modules below threshold."
  exit 1
else
  echo ""
  echo "Coverage check PASSED."
fi
