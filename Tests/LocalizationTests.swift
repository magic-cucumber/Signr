import XCTest
@testable import Signr

final class LocalizationTests: XCTestCase {
    private func languageBundle(_ language: String) throws -> Bundle {
        let appBundle = Bundle(for: AppModel.self)
        let path = try XCTUnwrap(appBundle.path(forResource: language, ofType: "lproj"))
        return try XCTUnwrap(Bundle(path: path))
    }

    func testEnglishAndChineseResourcesArePackaged() throws {
        let english = try languageBundle("en")
        let chinese = try languageBundle("zh-Hans")
        XCTAssertEqual(String(localized: "Sign & Install", bundle: english), "Sign & Install")
        XCTAssertEqual(String(localized: "Sign & Install", bundle: chinese), "签名并安装")
        XCTAssertEqual(String(localized: "Export", bundle: chinese), "导出")
        XCTAssertEqual(String(localized: "keep original", bundle: chinese), "保留原值")
    }

    func testInterpolationPreservesDeviceNamesAndErrorPayloads() throws {
        let chinese = try languageBundle("zh-Hans")
        let device = "Alice's iPhone 中文 % 🔑"
        let error = "Signing failed: certificate unavailable (%@)"
        XCTAssertEqual(String(localized: "Install to \(device)", bundle: chinese), "安装到 \(device)")
        XCTAssertEqual(String(localized: "Pairing failed: \(error)", bundle: chinese), "配对失败：\(error)")
        XCTAssertEqual(String(localized: "Missing tweaks: \(3)", bundle: chinese), "缺失的插件：3")
    }

    func testUntranslatedTextFallsBackToSource() throws {
        let chinese = try languageBundle("zh-Hans")
        XCTAssertEqual(chinese.localizedString(forKey: "Unknown source text", value: nil, table: nil), "Unknown source text")
    }

    func testHistoryKeepsStoredDestinationAndRawErrors() throws {
        let error = "Signing failed: certificate unavailable"
        let entry = HistoryEntry(date: Date(), appName: "Demo", bundleId: "com.example.demo", target: "Export", success: false, detail: error)
        let restored = try JSONDecoder().decode(HistoryEntry.self, from: JSONEncoder().encode(entry))
        XCTAssertEqual(restored.target, "Export")
        XCTAssertEqual(restored.localizedDetail, error)
    }
}
