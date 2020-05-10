import UIKit

public extension UIBarButtonItem {
    static func clearButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func deleteButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(title: "Delete", style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func doneButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func filterButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: .filter, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func sortButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: .sortAscending, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func moreButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: .more, style: .plain, target: target, action: action)
        barButtonItem.tintColor = .white
        return barButtonItem
    }

    static func dismissButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(image: .xmark, style: .plain, target: target, action: action)
        button.tintColor = .white
        return button
    }

    static func saveButton(target: UIViewController, action: Selector) -> UIBarButtonItem {
        let button = UIBarButtonItem(barButtonSystemItem: .save, target: target, action: action)
        button.tintColor = .white
        button.style = .done
        return button
    }
}
