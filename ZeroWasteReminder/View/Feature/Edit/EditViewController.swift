import Combine
import UIKit

public final class EditViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let dateButton = ExpirationDateButton(type: .system)
    private let datePicker = ExpirationDatePicker()

    private lazy var nameTextField: DefaultTextField = {
        let textField = DefaultTextField(placeholder: "")
        textField.textAlignment = .center
        return textField
    }()

    private let viewModel: EditViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel
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
            .sink { [weak self] in
                self?.viewModel.toggleExpirationDatePicker()
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        viewModel.$name
            .sink { [weak self] in self?.nameTextField.text = $0 }
            .store(in: &subscriptions)

        viewModel.expirationDate
            .sink { [weak self] in self?.dateButton.setTitle($0, for: .normal) }
            .store(in: &subscriptions)

        viewModel.isExpirationDateVisible
            .sink { [weak self] in self?.datePicker.setVisibility($0) }
            .store(in: &subscriptions)
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }
}
