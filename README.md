# PLSwiftApp

PLSwiftApp is a SwiftUI application baseline built on Apple's modern native stack.

## Architecture

- SwiftUI provides the UI layer and four-tab root shell.
- Observation powers app and feature state through `@Observable` view models.
- Swift Concurrency powers async Repository and DataSource calls.
- URLSession powers the reusable API client and remote message data source.
- SwiftData persists task state through the live data source.
- Dashboard summarizes Tasks and Messages through repository-backed async loading.
- Tasks is the first complete feature and supports load, add, edit, prioritize, due dates, toggle, search, filter, reorder, delete, and clear-completed flows.
- Messages supports async loading and refresh through a repository-backed view model.
- Settings persists telemetry preferences through UserDefaults.
- Dashboard, Messages, and Settings provide feature shells ready for expansion.

All app-level types use the `PL` prefix.
