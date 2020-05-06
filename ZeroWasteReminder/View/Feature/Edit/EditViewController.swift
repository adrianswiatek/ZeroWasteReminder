import Combine
import UIKit

public final class EditViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let stateLabel: UILabel = .defaultWithText("State")

    private let stateIndicatorLabel = StateIndicatorLabel()
    private let dateButton = ExpirationDateButton(type: .system)

    private lazy var nameTextField: DefaultTextField = {
        let textField = DefaultTextField(placeholder: "")
        textField.textAlignment = .center
        return textField
    }()

    private lazy var datePicker: ExpirationDatePicker = {
        let datePicker = ExpirationDatePicker()
        datePicker.isHidden = true
        return datePicker
    }()

    private let viewModel: EditViewModel
    private let controlsHeight: CGFloat
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel
        self.controlsHeight = 44
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
            dateButton.heightAnchor.constraint(equalToConstant: controlsHeight)
        ])

        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])

        view.addSubview(stateLabel)
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            stateLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor)
        ])

        view.addSubview(stateIndicatorLabel)
        NSLayoutConstraint.activate([
            stateIndicatorLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 8),
            stateIndicatorLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stateIndicatorLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stateIndicatorLabel.heightAnchor.constraint(equalToConstant: controlsHeight)
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

        datePicker.value
            .sink { [weak self] in self?.viewModel.setExpirationDate($0) }
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

        viewModel.state
            .sink { [weak self] in self?.stateIndicatorLabel.setState($0) }
            .store(in: &subscriptions)
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }
}
