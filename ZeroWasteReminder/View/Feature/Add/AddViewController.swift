import Combine
import UIKit

public final class AddViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleConfirm))

    private lazy var itemNameTextField: UITextField = {
        let textField = DefaultTextField(placeholder: "Item name")
        textField.becomeFirstResponder()
        textField.delegate = self
        return textField
    }()

    private lazy var expirationSectionView: ExpirationSectionView =
        .init(viewModel: viewModel)

    private let viewModel: AddViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel) {
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
        self.setupUserInterface()
    }

    private func setupUserInterface() {
        title = "Add item"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = doneButton

        view.addSubview(itemNameTextField)
        NSLayoutConstraint.activate([
            itemNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
            itemNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            itemNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        view.addSubview(expirationSectionView)
        NSLayoutConstraint.activate([
            expirationSectionView.topAnchor.constraint(equalTo: itemNameTextField.bottomAnchor, constant: 24),
            expirationSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            expirationSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expirationSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
        ])
    }

    private func bind() {
        viewModel.canSaveItem
            .sink { [weak self] in self?.doneButton.isEnabled = $0 }
            .store(in: &subscriptions)

        viewModel.$expirationTypeIndex
            .dropFirst()
            .sink { [weak self] _ in self?.itemNameTextField.resignFirstResponder() }
            .store(in: &subscriptions)
    }

    @objc
    private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc
    private func handleConfirm() {
        viewModel.saveItem()
            .sink { [weak self] _ in self?.dismiss(animated: true) }
            .store(in: &subscriptions)
    }
}

extension AddViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let itemName = textField.text else {
            preconditionFailure("itemName mustn't be nil")
        }

        viewModel.itemName = itemName
    }
}
