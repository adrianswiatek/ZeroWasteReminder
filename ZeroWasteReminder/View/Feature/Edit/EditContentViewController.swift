import Combine
import UIKit

public final class EditContentViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private lazy var nameTextField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.textAlignment = .center
        textField.delegate = self
        return textField
    }()

    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let dateButton = ExpirationDateButton(type: .system)
    private let datePicker = ExpirationDatePicker()

    private let stateIndicatorLabel = StateIndicatorLabel()
    private let stateLabel: UILabel = .defaultWithText("State")

    private let viewModel: EditViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(nameTextField)
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            expirationDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.topAnchor.constraint(equalTo: expirationDateLabel.bottomAnchor, constant: 8),
            dateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateButton.heightAnchor.constraint(equalToConstant: Metrics.controlsHeight)
        ])

        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(stateLabel)
        NSLayoutConstraint.activate([
            stateLabel.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 16),
            stateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(stateIndicatorLabel)
        NSLayoutConstraint.activate([
            stateIndicatorLabel.topAnchor.constraint(equalTo: stateLabel.bottomAnchor, constant: 8),
            stateIndicatorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateIndicatorLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stateIndicatorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateIndicatorLabel.heightAnchor.constraint(equalToConstant: Metrics.controlsHeight)
        ])
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
}

extension EditContentViewController {
    private enum Metrics {
        fileprivate static let controlsHeight: CGFloat = 44
    }
}

extension EditContentViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard var text = textField.text, let range = Range<String.Index>(range, in: text) else {
            preconditionFailure("Unable to create range.")
        }

        text.replaceSubrange(range, with: string)
        viewModel.name = text

        return false
    }
}
