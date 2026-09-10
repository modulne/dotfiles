#!/bin/bash

BUNDLE_ID="${1:-}"
APP_NAME="${2:-}"

if [ -n "$BUNDLE_ID" ]; then
  open -b "$BUNDLE_ID" 2>/dev/null && exit 0
fi

[ -n "$APP_NAME" ] && open -a "$APP_NAME"
