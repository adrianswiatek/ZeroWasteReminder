import Combine
import UIKit

public final class AddContentViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private let nameTextView: NameTextView = {
        let textView = NameTextView()
        textView.becomeFirstResponder()
        return textView
    }()

    private lazy var expirationSectionView: ExpirationSectionView =
        .init(viewModel: viewModel)

    private let notesLabel: UILabel = .defaultWithText("Notes")
    private let notesTextView: NotesTextView = .init()

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

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(nameTextView)
        NSLayoutConstraint.activate([
            nameTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationSectionView)
        NSLayoutConstraint.activate([
            expirationSectionView.topAnchor.constraint(equalTo: nameTextView.bottomAnchor, constant: 24),
            expirationSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expirationSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(notesLabel)
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(equalTo: expirationSectionView.bottomAnchor, constant: 24),
            notesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(notesTextView)
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(equalTo: notesLabel.bottomAnchor, constant: 8),
            notesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notesTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            notesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        nameTextView.value
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesTextView.value
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.$expirationTypeIndex
            .dropFirst()
            .sink { [weak self] _ in self?.nameTextView.resignFirstResponder() }
            .store(in: &subscriptions)
    }
}
