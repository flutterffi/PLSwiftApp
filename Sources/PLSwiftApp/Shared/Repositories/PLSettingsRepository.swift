protocol PLSettingsRepositoryProtocol: Sendable {
    func fetchSettings() async throws -> PLAppSettings
    func saveSettings(_ settings: PLAppSettings) async throws
}

struct PLSettingsRepository: PLSettingsRepositoryProtocol {
    private let dataSource: any PLSettingsDataSourceProtocol

    init(dataSource: any PLSettingsDataSourceProtocol = PLUserDefaultsSettingsDataSource()) {
        self.dataSource = dataSource
    }

    func fetchSettings() async throws -> PLAppSettings {
        try await dataSource.fetchSettings()
    }

    func saveSettings(_ settings: PLAppSettings) async throws {
        try await dataSource.saveSettings(settings)
    }
}
