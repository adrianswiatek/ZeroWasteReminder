import UIKit

public extension UIView {
    func addAndFill(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
