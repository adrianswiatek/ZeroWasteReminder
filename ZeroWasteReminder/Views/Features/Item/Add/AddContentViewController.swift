import AVFoundation
import Combine
import UIKit

public final class AddContentViewController: UIViewController {
    private let itemNameSectionView: ItemNameSectionView
    private let expirationSectionView: ExpirationSectionView
    private let notesSectionView: NotesSectionView
    private let alarmSectionView: AlarmSectionView

    private let photosLabel: UILabel = .defaultWithText(.localized(.photos))
    private let photosViewController: PhotosViewController

    private let viewModel: AddItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.itemNameSectionView = .init()
        self.expirationSectionView = .init(viewModel: viewModel)
        self.notesSectionView = .init()
        self.alarmSectionView = .init()

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
        itemNameSectionView.becomeFirstResponder()

        view.addSubview(itemNameSectionView)
        NSLayoutConstraint.activate([
            itemNameSectionView.topAnchor.constraint(equalTo: view.topAnchor),
            itemNameSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemNameSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationSectionView)
        NSLayoutConstraint.activate([
            expirationSectionView.topAnchor.constraint(
                equalTo: itemNameSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            expirationSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            expirationSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(notesSectionView)
        NSLayoutConstraint.activate([
            notesSectionView.topAnchor.constraint(
                equalTo: expirationSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            notesSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notesSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(alarmSectionView)
        NSLayoutConstraint.activate([
            alarmSectionView.topAnchor.constraint(
                equalTo: notesSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            alarmSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            alarmSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(photosLabel)
        NSLayoutConstraint.activate([
            photosLabel.topAnchor.constraint(
                equalTo: alarmSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
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
        itemNameSectionView.itemName
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesSectionView.notes
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)
    }
}

private extension AddContentViewController {
    enum Metrics {
        static let insideSectionPadding: CGFloat = 8
        static let betweenSectionsPadding: CGFloat = 24
    }
}
