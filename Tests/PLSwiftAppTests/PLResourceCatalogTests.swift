@testable import PLSwiftApp
import XCTest

@MainActor
final class PLResourceCatalogTests: XCTestCase {
    func testGeneratedStringResources() {
        XCTAssertEqual(PLString.Tasks.title, "Tasks")
        XCTAssertEqual(PLString.Empty.Tasks.title, "No tasks yet")
        XCTAssertEqual(PLString.Empty.Messages.message, "New updates will appear here.")
    }

    func testGeneratedJSONResources() {
        XCTAssertEqual(PLJSON.TaskSeeds.items.count, 3)
        XCTAssertEqual(PLJSON.MessageThreads.items.count, 2)
        XCTAssertEqual(PLJSON.FontTokens.families["body"] as? String, "SF Pro Text")
    }

    func testGeneratedAssetResources() {
        XCTAssertEqual(PLAsset.appIconPreview.name, "AppIconPreview")
        XCTAssertEqual(PLAsset.tabDashboardIcon.name, "TabDashboardIcon")
        XCTAssertEqual(PLAsset.emptyTasks.name, "EmptyTasks")
        XCTAssertEqual(PLAsset.backgroundTint.name, "BackgroundTint")
    }
}
