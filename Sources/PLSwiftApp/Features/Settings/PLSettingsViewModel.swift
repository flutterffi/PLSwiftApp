import Observation

@MainActor
@Observable
final class PLSettingsViewModel {
    var isAnalyticsEnabled = true
    var isCrashReportingEnabled = true
    var isLoading = false
    var errorMessage: String?

    private let repository: any PLSettingsRepositoryProtocol

    init(repository: any PLSettingsRepositoryProtocol = PLSettingsRepository()) {
        self.repository = repository
    }

    func loadSettings() async {
        isLoading = true
        errorMessage = nil

        do {
            apply(try await repository.fetchSettings())
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func analyticsChanged(_ isEnabled: Bool) async {
        isAnalyticsEnabled = isEnabled
        await saveSettings()
    }

    func crashReportingChanged(_ isEnabled: Bool) async {
        isCrashReportingEnabled = isEnabled
        await saveSettings()
    }

    private func saveSettings() async {
        do {
            try await repository.saveSettings(currentSettings)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private var currentSettings: PLAppSettings {
        PLAppSettings(
            isAnalyticsEnabled: isAnalyticsEnabled,
            isCrashReportingEnabled: isCrashReportingEnabled
        )
    }

    private func apply(_ settings: PLAppSettings) {
        isAnalyticsEnabled = settings.isAnalyticsEnabled
        isCrashReportingEnabled = settings.isCrashReportingEnabled
    }
}
