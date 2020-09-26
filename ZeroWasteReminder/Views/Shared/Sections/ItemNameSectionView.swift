import Combine
import UIKit

public final class ItemNameSectionView: UIView {
    private let nameLabel: UILabel
    private let nameTextView: NameTextView

    private let viewModel: AddItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddItemViewModel) {
        self.viewModel = viewModel

        self.nameLabel = .defaultWithText(.localized(.itemName))
        self.nameTextView = .init()

        self.subscriptions = []

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        nameTextView.becomeFirstResponder()
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        nameTextView.resignFirstResponder()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(nameTextView)
        NSLayoutConstraint.activate([
            nameTextView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor, constant: Metrics.spacing
            ),
            nameTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameTextView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: Metrics.spacing
            ),
            nameTextView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func bind() {
        nameTextView.value
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        viewModel.$expirationTypeIndex
            .dropFirst()
            .sink { [weak self] _ in self?.resignFirstResponder() }
            .store(in: &subscriptions)
    }
}

private extension ItemNameSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
