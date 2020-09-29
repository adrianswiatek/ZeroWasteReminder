import Combine
import UIKit

public final class EditContentViewController: UIViewController {
    private let itemNameSectionView: ItemNameSectionView
    private let notesSectionView: NotesSectionView
    private let expirationSectionView: EditExpirationSectionView
    private let alertSectionView: AlertSectionView
    private let photosSectionView: PhotosSectionView
    private let actionsSectionView: ActionsSectionView

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Metrics.spacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(top: Metrics.spacing, leading: 0, bottom: 0, trailing: 0)
        return stackView
    }()

    private let viewModel: EditItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.itemNameSectionView = .init()
        self.notesSectionView = .init()
        self.expirationSectionView = .init(viewModel: viewModel)
        self.alertSectionView = .init()
        self.photosSectionView = .init(viewModel: viewModel.photosViewModel)
        self.actionsSectionView = .init()

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
        stackView.addArrangedSubview(actionsSectionView)
    }

    private func setupView() {
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        actionsSectionView.removeButtonTap
            .sink { [weak self] in
                self?.viewModel.requestSubject.send(.removeCurrentItem)
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        actionsSectionView.moveButtonTap
            .sink { [weak self] in
                self?.viewModel.requestSubject.send(.moveCurrentItem)
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        itemNameSectionView.itemName
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesSectionView.notes
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.$name
            .sink { [weak self] in self?.itemNameSectionView.setText($0) }
            .store(in: &subscriptions)

        viewModel.$notes
            .sink { [weak self] in self?.notesSectionView.setText($0) }
            .store(in: &subscriptions)
    }
}

extension EditContentViewController {
    private enum Metrics {
        static let spacing: CGFloat = 24
    }
}
