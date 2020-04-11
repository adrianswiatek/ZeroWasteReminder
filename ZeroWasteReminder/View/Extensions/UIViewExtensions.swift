import UIKit

public extension UIView {
    func fill(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}
