import UIKit

public extension UIView {
    func addAndFill(_ subview: UIView, insets: UIEdgeInsets = .zero) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.right)
        ])
    }
}
