import Combine
import UIKit

public final class EditViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let datePicker = ExpirationDatePicker()

    private lazy var nameTextField: AddItemTextField = {
        let textField = AddItemTextField(placeholder: "")
        textField.textColor = .label
        textField.text = originalItem.name
        return textField
    }()

    private lazy var dateButton: ExpirationDateButton = {
        let button = ExpirationDateButton(type: .system)
        if case .date(let date) = originalItem.expiration {
            let dateFormatter: DateFormatter = .fullDateFormatter
            button.setTitle(dateFormatter.string(from: date), for: .normal)
        } else {
            button.setTitle("[Not defined]", for: .normal)
        }
        return button
    }()

    private let originalItem: Item
    private var subscriptions: Set<AnyCancellable>

    public init(_ item: Item) {
        self.originalItem = item
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.setupUserInterface()
        self.setupGestureRecognizer()
        self.bind()
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

        view.addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.topAnchor.constraint(equalTo: expirationDateLabel.bottomAnchor, constant: 8),
            dateButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            dateButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            dateButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
    }

    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func bind() {
        dateButton.tap
            .sink { print("Button has been tapped") }
            .store(in: &subscriptions)
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }
}
