import Combine
import UIKit

public final class EditViewController: UIViewController {
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = "Item name"
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    private lazy var nameTextField: AddItemTextField = {
        let textField = AddItemTextField(placeholder: "")
        textField.textColor = .label
        textField.text = originalItem.name
        return textField
    }()

    private lazy var expirationDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.text = "Expiration date"
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()

    private let originalItem: Item

    public init(_ item: Item) {
        self.originalItem = item
        super.init(nibName: nil, bundle: nil)
        self.setupUserInterface()
        self.setupGestureRecognizer()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupUserInterface() {
        view.backgroundColor = .systemBackground

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])

        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        view.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            expirationDateLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])
    }

    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }
}
