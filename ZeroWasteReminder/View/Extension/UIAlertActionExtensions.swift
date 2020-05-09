import UIKit

public extension UIAlertAction {
    enum Action: String {
        case yes = "Yes"
        case cancel = "Cancel"
        case deleteAll = "Remove all"
        case selectItems = "Select items"
    }

    static func yes(withStyle style: Style, handler: @escaping (UIAlertAction) -> Void) -> Self {
        .init(title: Action.yes.rawValue, style: style, handler: handler)
    }

    static func cancel(handler: @escaping (UIAlertAction) -> Void) -> Self {
        .init(title: Action.cancel.rawValue, style: .cancel, handler: handler)
    }

    static func selectItems(handler: @escaping (UIAlertAction) -> Void) -> Self {
        .init(title: Action.selectItems.rawValue, style: .default, handler: handler)
    }

    static func deleteAll(handler: @escaping (UIAlertAction) -> Void) -> Self {
        .init(title: Action.deleteAll.rawValue, style: .destructive, handler: handler)
    }
}
