# Flutter Feed Migration

This directory contains a prototype migration of the SpoonApp feed to Flutter. The code is located in `spoonapp_flutter/` and provides a minimal example of how the feed page might look using Flutter widgets.

## Structure

- `lib/widgets/feed/` – basic feed list widget.
- `lib/widgets/stories/` – story list displayed above the feed.
- `lib/widgets/topbar/` – top application bar with navigation icons.
- `lib/services/` – placeholder for future DynamoDB and S3 integration.

The `pubspec.yaml` file includes placeholder dependencies for AWS DynamoDB, S3, `uuid`, and `provider` for state management.

Binary assets such as icons are omitted from version control. Run `flutter create .` inside
`spoonapp_flutter` to regenerate the default icon set.

Once Flutter is installed, execute `./run_feed.sh` to fetch packages and start the example.

The feed page includes left and right side menus that slide out below the top bar. While a menu is open the feed remains fully scrollable and interactive.
