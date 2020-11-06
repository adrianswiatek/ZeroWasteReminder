import UIKit

public extension UIBarButtonItem {
    static func clearButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: .localized(.clear), primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func deleteButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(title: .localized(.remove), primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func doneButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func filterButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.lineHorizontal3DecreaseCircle)
        let button = UIBarButtonItem(image: image, primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func searchButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(systemItem: .search, primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func sortButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.arrowUpCircle)
        let button = UIBarButtonItem(image: image, primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func moreButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.ellipsisCircle)
        let button = UIBarButtonItem(image: image, primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }

    static func dismissButton(action: @escaping () -> Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(image: .fromSymbol(.xmark), primaryAction: UIAction { _ in action() })
        button.tintColor = .white
        return button
    }
}
