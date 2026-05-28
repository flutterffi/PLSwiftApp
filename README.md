# PLSwiftApp

PLSwiftApp is a SwiftUI application baseline built on Apple's modern native stack.

## Architecture

- SwiftUI provides the UI layer and four-tab root shell.
- Observation powers app and feature state through `@Observable` view models.
- Swift Concurrency powers async Repository and DataSource calls.
- Tasks is the first complete feature and supports load, add, toggle, delete, and clear-completed flows.
- Dashboard, Messages, and Settings provide feature shells ready for expansion.

All app-level types use the `PL` prefix.
