import UIKit

public extension UIAlertAction {
    enum Action: String {
        case ok = "OK"
        case yes = "Yes"
        case cancel = "Cancel"
        case deleteAll = "Remove all"
        case shareList = "Share list"
        case selectItems = "Select items"
    }

    static var ok: UIAlertAction {
        .init(title: Action.ok.rawValue, style: .default)
    }

    static func yes(withStyle style: Style, handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: Action.yes.rawValue, style: style, handler: handler)
    }

    static func cancel(handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: Action.cancel.rawValue, style: .cancel, handler: handler)
    }

    static func deleteAll(handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: Action.deleteAll.rawValue, style: .destructive, handler: handler)
    }

    static func shareList(handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: Action.shareList.rawValue, style: .default, handler: handler)
    }

    static func selectItems(handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: Action.selectItems.rawValue, style: .default, handler: handler)
    }
}
