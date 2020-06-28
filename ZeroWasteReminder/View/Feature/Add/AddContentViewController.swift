import AVFoundation
import Combine
import UIKit

public final class AddContentViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText(.localized(.itemName))
    private let nameTextView: NameTextView = {
        let textView = NameTextView()
        textView.becomeFirstResponder()
        return textView
    }()

    private lazy var expirationSectionView: ExpirationSectionView =
        .init(viewModel: viewModel)

    private let notesLabel: UILabel = .defaultWithText(.localized(.notes))
    private let notesTextView: NotesTextView

    private let photosLabel: UILabel = .defaultWithText(.localized(.photos))
    private let photosViewController: PhotosViewController

    private let viewModel: AddViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.notesTextView = .init()
        self.photosViewController = .init(viewModel: viewModel.photosViewModel)

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
            nameTextView.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationSectionView)
        NSLayoutConstraint.activate([
            expirationSectionView.topAnchor.constraint(
                equalTo: nameTextView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            expirationSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expirationSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(notesLabel)
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(
                equalTo: expirationSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            notesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(notesTextView)
        NSLayoutConstraint.activate([
            notesTextView.topAnchor.constraint(
                equalTo: notesLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            notesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(photosLabel)
        NSLayoutConstraint.activate([
            photosLabel.topAnchor.constraint(
                equalTo: notesTextView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            photosLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        addChild(photosViewController)
        view.addSubview(photosViewController.view)
        photosViewController.didMove(toParent: self)

        NSLayoutConstraint.activate([
            photosViewController.view.topAnchor.constraint(
                equalTo: photosLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            photosViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            photosViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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

private extension AddContentViewController {
    enum Metrics {
        static let insideSectionPadding: CGFloat = 8
        static let betweenSectionsPadding: CGFloat = 24
    }
}
