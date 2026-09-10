#!/bin/bash

# Keep a single Paneru subscription alive and turn every Paneru state event
# into a Sketchybar event. The renderer re-queries the complete state so it
# never has to reconstruct state from a partial subscription payload.

set -u

TMP_ROOT="${TMPDIR:-/tmp}"
LOCK_DIR="$TMP_ROOT/sketchybar-paneru-listener.lock"
PID_FILE="$LOCK_DIR/pid"
EVENT_NAME="paneru_state_changed"
RETRY_DELAY=1
DEBOUNCE_DIR="$TMP_ROOT/sketchybar-paneru-debounce"
DEBOUNCE_LOCK="$DEBOUNCE_DIR/active"
DEBOUNCE_PENDING="$DEBOUNCE_DIR/pending"

acquire_lock() {
  if mkdir "$LOCK_DIR" 2>/dev/null; then
    printf '%s\n' "$$" > "$PID_FILE"
    return 0
  fi

  if [ -r "$PID_FILE" ]; then
    EXISTING_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
    if [ -n "$EXISTING_PID" ] && kill -0 "$EXISTING_PID" 2>/dev/null; then
      return 1
    fi
  fi

  rm -f "$PID_FILE"
  rmdir "$LOCK_DIR" 2>/dev/null || return 1
  mkdir "$LOCK_DIR" 2>/dev/null || return 1
  printf '%s\n' "$$" > "$PID_FILE"
  return 0
}

cleanup() {
  rm -f "$DEBOUNCE_PENDING"
  rmdir "$DEBOUNCE_LOCK" 2>/dev/null || true
  rmdir "$DEBOUNCE_DIR" 2>/dev/null || true
  rm -f "$PID_FILE"
  rmdir "$LOCK_DIR" 2>/dev/null || true
}

schedule_refresh() {
  mkdir "$DEBOUNCE_DIR" 2>/dev/null || true
  : > "$DEBOUNCE_PENDING"

  if ! mkdir "$DEBOUNCE_LOCK" 2>/dev/null; then
    return 0
  fi

  (
    while :; do
      rm -f "$DEBOUNCE_PENDING"
      sleep 0.08

      # Keep waiting while events continue arriving in the same burst.
      if [ -f "$DEBOUNCE_PENDING" ]; then
        continue
      fi

      sketchybar --trigger "$EVENT_NAME" >/dev/null 2>&1 || true
      sleep 0.02
      if [ -f "$DEBOUNCE_PENDING" ]; then
        continue
      fi

      rmdir "$DEBOUNCE_LOCK" 2>/dev/null || true
      exit 0
    done
  ) &
}

acquire_lock || exit 0
trap cleanup EXIT INT TERM
rm -f "$DEBOUNCE_PENDING"
rmdir "$DEBOUNCE_LOCK" 2>/dev/null || true

while :; do
  # Refresh once when a daemon connection becomes available. Back off while
  # Paneru is unavailable so a broken daemon does not create query/log spam.
  PANERU_STATE="$(paneru query state --json 2>/dev/null)"
  if [ -z "$PANERU_STATE" ] \
    || ! printf '%s\n' "$PANERU_STATE" | jq -e '(.virtual_workspaces? | type == "array")' >/dev/null 2>&1; then
    sleep "$RETRY_DELAY"
    if [ "$RETRY_DELAY" -lt 30 ]; then
      RETRY_DELAY=$((RETRY_DELAY * 2))
    fi
    continue
  fi
  RETRY_DELAY=1
  schedule_refresh

  while IFS= read -r event; do
    [ -z "$event" ] && continue
    schedule_refresh
  done < <(paneru subscribe --json 2>/dev/null)

  # Retry after a Paneru daemon restart or a dropped subscription.
  sleep "$RETRY_DELAY"
done
