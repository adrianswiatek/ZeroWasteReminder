import UIKit

public extension UILabel {
    static func defaultWithText(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }
}
