import Combine
import UIKit

public final class AddContentViewController: UIViewController {
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

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(itemNameTextField)
        NSLayoutConstraint.activate([
            itemNameTextField.topAnchor.constraint(equalTo: view.topAnchor),
            itemNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationSectionView)
        NSLayoutConstraint.activate([
            expirationSectionView.topAnchor.constraint(equalTo: itemNameTextField.bottomAnchor, constant: 24),
            expirationSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expirationSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            expirationSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        viewModel.$expirationTypeIndex
            .dropFirst()
            .sink { [weak self] _ in self?.itemNameTextField.resignFirstResponder() }
            .store(in: &subscriptions)
    }
}

extension AddContentViewController: UITextFieldDelegate {
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
