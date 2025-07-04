#!/bin/sh
# Simple helper script to run the Flutter feed example

ASSET="assets/images/spoonapp.png"
if [ ! -f "$ASSET" ] && [ -f ../static/img/spoonapp.png ]; then
  mkdir -p "$(dirname "$ASSET")"
  cp ../static/img/spoonapp.png "$ASSET"
fi

flutter pub get
flutter run
