# spoonapp_flutter

Prototype Flutter feed for SpoonApp.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Binary image assets were removed from version control. If you need the default
app icons, run `flutter create .` inside this directory to regenerate them.

Copy `../static/img/spoonapp.png` to `assets/images/spoonapp.png` before
running the Flutter app. The included `run_feed.sh` script performs this step
automatically if the file is missing. After cloning the project run
`flutter pub get` to download the required packages.

To run the sample feed:

```bash
./run_feed.sh
```

The top bar now includes left and right menu buttons that open their
corresponding drawers. A profile button on the right navigates to a simple
profile page.

See the [online documentation](https://docs.flutter.dev/) for general Flutter
guides and API reference.
