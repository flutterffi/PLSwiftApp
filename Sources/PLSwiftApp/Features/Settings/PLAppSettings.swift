struct PLAppSettings: Equatable, Sendable {
    var isAnalyticsEnabled: Bool
    var isCrashReportingEnabled: Bool

    static let defaults = PLAppSettings(
        isAnalyticsEnabled: true,
        isCrashReportingEnabled: true
    )
}
