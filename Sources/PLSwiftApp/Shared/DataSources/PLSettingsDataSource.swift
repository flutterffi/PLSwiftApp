import Foundation

protocol PLSettingsDataSourceProtocol: Sendable {
    func fetchSettings() async throws -> PLAppSettings
    func saveSettings(_ settings: PLAppSettings) async throws
}

actor PLInMemorySettingsDataSource: PLSettingsDataSourceProtocol {
    private var settings: PLAppSettings

    init(settings: PLAppSettings = .defaults) {
        self.settings = settings
    }

    func fetchSettings() async throws -> PLAppSettings {
        settings
    }

    func saveSettings(_ settings: PLAppSettings) async throws {
        self.settings = settings
    }
}

actor PLUserDefaultsSettingsDataSource: PLSettingsDataSourceProtocol {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchSettings() async throws -> PLAppSettings {
        PLAppSettings(
            isAnalyticsEnabled: bool(forKey: Keys.analytics, defaultValue: true),
            isCrashReportingEnabled: bool(forKey: Keys.crashReporting, defaultValue: true)
        )
    }

    func saveSettings(_ settings: PLAppSettings) async throws {
        userDefaults.set(settings.isAnalyticsEnabled, forKey: Keys.analytics)
        userDefaults.set(settings.isCrashReportingEnabled, forKey: Keys.crashReporting)
    }

    private func bool(forKey key: String, defaultValue: Bool) -> Bool {
        guard userDefaults.object(forKey: key) != nil else {
            return defaultValue
        }
        return userDefaults.bool(forKey: key)
    }

    private enum Keys {
        static let analytics = "pl.settings.analytics"
        static let crashReporting = "pl.settings.crashReporting"
    }
}
