import AVFoundation
import Combine
import UIKit

public final class AddContentViewController: UIViewController {
    private let itemNameSectionView: ItemNameSectionView
    private let expirationSectionView: ExpirationSectionView
    private let notesSectionView: NotesSectionView
    private let alertSectionView: AlertSectionView
    private let photosSectionView: PhotosSectionView

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Metrics.spacing
        return stackView
    }()

    private let viewModel: AddItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.itemNameSectionView = .init()
        self.expirationSectionView = .init(viewModel: viewModel)
        self.notesSectionView = .init()
        self.alertSectionView = .init()
        self.photosSectionView = .init(viewModel: viewModel.photosViewModel)

        super.init(nibName: nil, bundle: nil)

        self.setupStackView()
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupStackView() {
        stackView.addArrangedSubview(itemNameSectionView)
        stackView.addArrangedSubview(expirationSectionView)
        stackView.addArrangedSubview(notesSectionView)
        stackView.addArrangedSubview(alertSectionView)
        stackView.addArrangedSubview(photosSectionView)
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false
        itemNameSectionView.becomeFirstResponder()

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        itemNameSectionView.itemName
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesSectionView.notes
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        alertSectionView.tap
            .sink { [weak self] in self?.viewModel.requestSubject.send(.setAlert) }
            .store(in: &subscriptions)

        viewModel.$alertOption
            .sink { [weak self] in self?.alertSectionView.setTitle($0.formatted(.fullDate)) }
            .store(in: &subscriptions)
    }
}

private extension AddContentViewController {
    enum Metrics {
        static let spacing: CGFloat = 24
    }
}
