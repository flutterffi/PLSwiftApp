# PLSwiftApp

PLSwiftApp is a SwiftUI application baseline built on Apple's modern native stack.

## Architecture

- SwiftUI provides the UI layer and four-tab root shell.
- Observation powers app and feature state through `@Observable` view models.
- Swift Concurrency powers async Repository and DataSource calls.
- URLSession powers the reusable API client and remote message data source.
- SwiftData persists task state through the live data source.
- SwiftGen generates type-safe accessors for app resources.
- Dashboard summarizes Tasks, priority, due dates, and Messages through repository-backed async loading.
- Tasks is the first complete feature and supports load, add, edit, prioritize, due dates, toggle, search, filter, sort, reorder, delete, and clear-completed flows.
- Messages supports async loading, refresh, search, unread filtering, and repository-backed read-state toggles.
- Settings persists telemetry preferences through UserDefaults.
- Dashboard, Messages, and Settings provide feature shells ready for expansion.

All app-level types use the `PL` prefix.

## Resources

Resources live in `Sources/PLSwiftApp/Resources`.

- `Assets.xcassets` contains sample app icon, tab icon, empty-state image, and color token assets.
- `Localization/en.lproj/Localizable.strings` contains localized UI strings.
- `Mock` contains JSON seed data and font design tokens.

SwiftGen runs through the Swift Package Manager plugin during builds and generates typed accessors from `swiftgen.yml` into derived sources. To run resource generation manually:

```sh
swift package --allow-writing-to-package-directory generate-code-for-resources
```
