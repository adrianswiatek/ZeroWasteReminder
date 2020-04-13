import UIKit

public final class AddViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(handleDismiss)
        )
        button.tintColor = .white
        return button
    }()

    private lazy var confirmButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(systemName: "checkmark.circle"),
            style: .plain,
            target: self,
            action: #selector(handleDismiss)
        )
        button.tintColor = .white
        return button
    }()

    private let itemNameTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Item name")
        textField.becomeFirstResponder()
        textField.clearButtonMode = .always
        return textField
    }()

    private let expirationDateView = ExpirationDateView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUserInterface()
    }

    private func setupUserInterface() {
        title = "Add item"
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = confirmButton

        view.addSubview(itemNameTextField)
        NSLayoutConstraint.activate([
            itemNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            itemNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            itemNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        view.addSubview(expirationDateView)
        NSLayoutConstraint.activate([
            expirationDateView.topAnchor.constraint(equalTo: itemNameTextField.bottomAnchor, constant: 32),
            expirationDateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            expirationDateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expirationDateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
}
