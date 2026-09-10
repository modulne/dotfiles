#!/bin/bash

# Render the Paneru window state as grouped Sketchybar items.
#
# Paneru exposes both the native macOS workspace id and its virtual workspace
# number. They form the group key together, because virtual workspace numbers
# can repeat on different native Spaces.

set -u

TMP_ROOT="${TMPDIR:-/tmp}"
ITEMS_FILE="$TMP_ROOT/sketchybar-paneru-items"
ORDER_FILE="$TMP_ROOT/sketchybar-paneru-order"
NEXT_ITEMS_FILE="$ITEMS_FILE.next.$$"
LOCK_DIR="$TMP_ROOT/sketchybar-paneru-render.lock"
FOCUS_HELPER="$HOME/.config/sketchybar/plugins/focus_app.sh"

hide_stale_items() {
  local rendered_items_file="$1"

  if [ -f "$ITEMS_FILE" ] && [ -f "$rendered_items_file" ]; then
    while IFS= read -r item_name; do
      [ -z "$item_name" ] && continue
      if ! grep -Fqx "$item_name" "$rendered_items_file"; then
        sketchybar --set "$item_name" drawing=off 2>/dev/null || true
      fi
    done < "$ITEMS_FILE"
  fi
}

finish_render() {
  local rendered_items_file="$1"
  local order="$2"
  local previous_order

  # Turn off only items that disappeared. Current items stay visible while
  # their labels/colors are updated, so a refresh cannot blank the bar.
  hide_stale_items "$rendered_items_file"

  previous_order="$(cat "$ORDER_FILE" 2>/dev/null || true)"
  if [ -n "$order" ] && [ "$order" != "$previous_order" ]; then
    sketchybar --reorder $order windows_trigger 2>/dev/null || true
  fi

  mv "$rendered_items_file" "$ITEMS_FILE"
  printf '%s\n' "$order" > "$ORDER_FILE"
}

render_fallback_apps() {
  # Paneru 0.4.4 can temporarily reject a query while its restored window
  # connections are unavailable. Keep the previous app display usable until
  # the subscription reconnects and a grouped Paneru state is available.
  local windows focused app item index order new_items background text

  windows="$(osascript <<'APPLESCRIPT'
set appList to {}
tell application "System Events"
  set procs to every process whose background only is false
  repeat with p in procs
    try
      if (count of windows of p) > 0 then
        set appName to name of p
        if appName is not in appList then set end of appList to appName
      end if
    end try
  end repeat
end tell
set output to ""
repeat with a in appList
  set output to output & a & linefeed
end repeat
return output
APPLESCRIPT
  2>/dev/null)"
  focused="$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)"

  index=0
  order=""
  new_items=""

  while IFS= read -r app; do
    [ -z "$app" ] && continue
    item="paneru.fallback.app.${index}"

    if [ "$app" = "$focused" ]; then
      background=0xff9bd692
      text=0xff000000
    else
      background=0xff0D0B1A
      text=0xffffffff
    fi

    sketchybar --add item "$item" left 2>/dev/null || true
    sketchybar --set "$item" \
                 drawing=on \
                 click_script="$FOCUS_HELPER '' $(printf '%q' "$app")" \
                 label="$app" \
                 label.color=$text \
                 label.font="SF Pro:Semibold:13" \
                 label.padding_left=8 \
                 label.padding_right=8 \
                 icon.drawing=off \
                 background.drawing=on \
                 background.color=$background \
                 background.height=26 \
                 background.corner_radius=6 \
                 padding_left=4 \
                 padding_right=0

    new_items="${new_items}${item}\n"
    order="${order}${item} "
    index=$((index + 1))
  done <<< "$windows"

  printf '%b' "$new_items" > "$NEXT_ITEMS_FILE"
  finish_render "$NEXT_ITEMS_FILE" "$order"
}

# Sketchybar can receive several subscription events close together. Let one
# render own the dynamic item set at a time.
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi
trap 'rm -f "$NEXT_ITEMS_FILE"; rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT

STATE="$(paneru query state --json 2>/dev/null)"
if [ -z "$STATE" ] \
  || ! printf '%s\n' "$STATE" | jq -e '(.virtual_workspaces? | type == "array")' >/dev/null 2>&1; then
  render_fallback_apps
  exit 0
fi

PANERU_GROUPS="$(printf '%s\n' "$STATE" | jq -c '
  [
    (.virtual_workspaces // [])[]
    | select(((.windows // []) | length) > 0)
    | {
        native_id: (.native_workspace_id // null),
        native_sort: (.native_workspace_id // -1),
        virtual_number: (.number // 0),
        active: (.active // false),
        apps: [
          (.windows // [])[]
          | select((.app_name // "") != "")
          | {
              app: .app_name,
              bundle_id: (.bundle_id // ""),
              focused: (.focused // false)
            }
        ]
      }
  ]
  | sort_by([.native_sort, .virtual_number])
' 2>/dev/null)"

if [ -z "$PANERU_GROUPS" ] || ! printf '%s\n' "$PANERU_GROUPS" | jq -e 'type == "array"' >/dev/null 2>&1; then
  render_fallback_apps
  exit 0
fi

GROUP_COUNT="$(printf '%s\n' "$PANERU_GROUPS" | jq 'length')"
GROUP_INDEX=0
NEW_ITEMS=""
ORDER=""

while IFS= read -r group; do
  [ -z "$group" ] && continue

  VIRTUAL_NUMBER="$(printf '%s\n' "$group" | jq -r '.virtual_number')"
  ACTIVE="$(printf '%s\n' "$group" | jq -r '.active')"
  SPACE_LABEL="$VIRTUAL_NUMBER"

  SPACE_ITEM="paneru.space.${GROUP_INDEX}"
  if [ "$ACTIVE" = "true" ]; then
    SPACE_BACKGROUND=0xff9bd692
    SPACE_TEXT=0xff000000
  else
    SPACE_BACKGROUND=0xff0D0B1A
    SPACE_TEXT=0xff9bd692
  fi

  sketchybar --add item "$SPACE_ITEM" left 2>/dev/null || true
  sketchybar --set "$SPACE_ITEM" \
               drawing=on \
               label="$SPACE_LABEL" \
               label.color=$SPACE_TEXT \
               label.font="SF Pro:Semibold:11" \
               label.padding_left=8 \
               label.padding_right=8 \
               icon.drawing=off \
               background.drawing=on \
               background.color=$SPACE_BACKGROUND \
               background.height=26 \
               background.corner_radius=6 \
               padding_left=4 \
               padding_right=0

  NEW_ITEMS="${NEW_ITEMS}${SPACE_ITEM}\n"
  ORDER="${ORDER}${SPACE_ITEM} "

  APP_INDEX=0
  while IFS= read -r app; do
    [ -z "$app" ] && continue

    APP_NAME="$(printf '%s\n' "$app" | jq -r '.app')"
    BUNDLE_ID="$(printf '%s\n' "$app" | jq -r '.bundle_id // ""')"
    FOCUSED="$(printf '%s\n' "$app" | jq -r '.focused')"
    APP_ITEM="paneru.app.${GROUP_INDEX}.${APP_INDEX}"

    if [ "$FOCUSED" = "true" ] && [ "$ACTIVE" = "true" ]; then
      APP_BACKGROUND=0xff9bd692
      APP_TEXT=0xff000000
    else
      APP_BACKGROUND=0xff0D0B1A
      APP_TEXT=0xffffffff
    fi

    # printf %q keeps app names and bundle ids safe inside Sketchybar's
    # click_script shell command.
    FOCUS_SCRIPT="$FOCUS_HELPER $(printf '%q' "$BUNDLE_ID") $(printf '%q' "$APP_NAME")"

    sketchybar --add item "$APP_ITEM" left 2>/dev/null || true
    sketchybar --set "$APP_ITEM" \
                 drawing=on \
                 click_script="$FOCUS_SCRIPT" \
                 label="$APP_NAME" \
                 label.color=$APP_TEXT \
                 label.font="SF Pro:Semibold:13" \
                 label.padding_left=8 \
                 label.padding_right=8 \
                 icon.drawing=off \
                 background.drawing=on \
                 background.color=$APP_BACKGROUND \
                 background.height=26 \
                 background.corner_radius=6 \
                 padding_left=4 \
                 padding_right=0

    NEW_ITEMS="${NEW_ITEMS}${APP_ITEM}\n"
    ORDER="${ORDER}${APP_ITEM} "
    APP_INDEX=$((APP_INDEX + 1))
  done < <(printf '%s\n' "$group" | jq -c '.apps[]')

  if [ "$GROUP_INDEX" -lt $((GROUP_COUNT - 1)) ]; then
    GAP_ITEM="paneru.gap.${GROUP_INDEX}"
    sketchybar --add item "$GAP_ITEM" left 2>/dev/null || true
    sketchybar --set "$GAP_ITEM" \
                 drawing=on \
                 width=12 \
                 icon.drawing=off \
                 label.drawing=off \
                 background.drawing=off \
                 padding_left=0 \
                 padding_right=0
    NEW_ITEMS="${NEW_ITEMS}${GAP_ITEM}\n"
    ORDER="${ORDER}${GAP_ITEM} "
  fi

  GROUP_INDEX=$((GROUP_INDEX + 1))
done < <(printf '%s\n' "$PANERU_GROUPS" | jq -c '.[]')

printf '%b' "$NEW_ITEMS" > "$NEXT_ITEMS_FILE"
finish_render "$NEXT_ITEMS_FILE" "$ORDER"
