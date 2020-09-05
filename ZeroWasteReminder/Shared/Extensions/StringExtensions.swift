import Foundation

public extension String {
    static var empty: String {
        ""
    }

    static func localized(_ key: LocalizedText) -> String {
        NSLocalizedString(key.rawValue, tableName: nil, bundle: .main, value: key.rawValue, comment: "")
    }
}
