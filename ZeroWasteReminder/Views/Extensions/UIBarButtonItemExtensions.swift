import UIKit

public extension UIBarButtonItem {
    static func clearButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(title: .localized(.clear), style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func deleteButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(title: .localized(.remove), style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func doneButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func filterButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.lineHorizontal3DecreaseCircle)
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func searchButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func sortButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.arrowUpCircle)
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func moreButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let image = UIImage.fromSymbol(.ellipsisCircle)
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func dismissButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(image: .fromSymbol(.xmark), style: .plain, target: target, action: action)
        button.tintColor = .white
        return button
    }
}
