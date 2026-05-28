@testable import PLSwiftApp
import Foundation
import XCTest

@MainActor
final class PLSettingsViewModelTests: XCTestCase {
    func testLoadSettings() async {
        let repository = PLSettingsRepository(
            dataSource: PLInMemorySettingsDataSource(
                settings: PLAppSettings(
                    isAnalyticsEnabled: false,
                    isCrashReportingEnabled: true
                )
            )
        )
        let viewModel = PLSettingsViewModel(repository: repository)

        await viewModel.loadSettings()

        XCTAssertFalse(viewModel.isAnalyticsEnabled)
        XCTAssertTrue(viewModel.isCrashReportingEnabled)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSaveSettings() async throws {
        let dataSource = PLInMemorySettingsDataSource()
        let repository = PLSettingsRepository(dataSource: dataSource)
        let viewModel = PLSettingsViewModel(repository: repository)

        await viewModel.analyticsChanged(false)
        await viewModel.crashReportingChanged(false)

        let savedSettings = try await repository.fetchSettings()
        XCTAssertEqual(
            savedSettings,
            PLAppSettings(
                isAnalyticsEnabled: false,
                isCrashReportingEnabled: false
            )
        )
    }
}

final class PLSettingsDataSourceTests: XCTestCase {
    func testUserDefaultsDataSourcePersistsSettings() async throws {
        let suiteName = "PLSettingsViewModelTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        let dataSource = PLUserDefaultsSettingsDataSource(userDefaults: userDefaults)
        let expectedSettings = PLAppSettings(
            isAnalyticsEnabled: false,
            isCrashReportingEnabled: false
        )

        let defaultSettings = try await dataSource.fetchSettings()
        try await dataSource.saveSettings(expectedSettings)
        let savedSettings = try await dataSource.fetchSettings()

        XCTAssertEqual(defaultSettings, .defaults)
        XCTAssertEqual(savedSettings, expectedSettings)
    }
}
