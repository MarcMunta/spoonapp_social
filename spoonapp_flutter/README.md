# spoonapp_flutter

Prototype Flutter feed for SpoonApp.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

Binary image assets were removed from version control. If you need the default
app icons, run `flutter create .` inside this directory to regenerate them.

All required images are embedded directly in the source using base64 strings, so
no additional setup is necessary. After cloning the project run
`flutter pub get` to download the required packages.

To run the sample feed:

```bash
./run_feed.sh
```

The top bar now includes left and right menu buttons that open their
corresponding drawers. A profile button on the right navigates to a simple
profile page. The picture shows a small `+` icon to upload a new story using
`file_picker`. Uploaded images or videos appear in the stories carousel and
disappear automatically after 24 hours.

See the [online documentation](https://docs.flutter.dev/) for general Flutter
guides and API reference.
