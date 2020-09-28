import Combine
import UIKit

public final class EditContentViewController: UIViewController {
    private let itemNameSectionView: ItemNameSectionView
    private let notesSectionView: NotesSectionView
    private let expirationSectionView: EditExpirationSectionView
    private let alarmSectionView: AlarmSectionView
    private let photosSectionView: PhotosSectionView
    private let actionsSectionView: ActionsSectionView

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Metrics.spacing
        return stackView
    }()

    private let viewModel: EditItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.itemNameSectionView = .init()
        self.notesSectionView = .init()
        self.expirationSectionView = .init()
        self.alarmSectionView = .init()
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
        stackView.addArrangedSubview(alarmSectionView)
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
        expirationSectionView.tap
            .sink { [weak self] in
                if case .dateButton = $0 {
                    self?.viewModel.toggleExpirationDatePicker()
                } else if case .removeDateButton = $0 {
                    self?.viewModel.setExpirationDate(nil)
                }
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

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

        expirationSectionView.datePickerValue
            .sink { [weak self] in self?.viewModel.setExpirationDate($0) }
            .store(in: &subscriptions)

        itemNameSectionView.itemName
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesSectionView.notes
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.isRemoveDateButtonEnabled
            .sink { [weak self] in self?.expirationSectionView.setRemoveButtonEnabled($0) }
            .store(in: &subscriptions)

        viewModel.$name
            .sink { [weak self] in self?.itemNameSectionView.setText($0) }
            .store(in: &subscriptions)

        viewModel.$notes
            .sink { [weak self] in self?.notesSectionView.setText($0) }
            .store(in: &subscriptions)

        viewModel.expirationDate
            .sink { [weak self] in self?.expirationSectionView.setExpiration($0.date, $0.formatted) }
            .store(in: &subscriptions)

        viewModel.isExpirationDateVisible
            .sink { [weak self] in self?.expirationSectionView.setDatePickerVisibility($0) }
            .store(in: &subscriptions)

        viewModel.state
            .sink { [weak self] in self?.expirationSectionView.setState($0) }
            .store(in: &subscriptions)
    }
}

extension EditContentViewController {
    private enum Metrics {
        static let spacing: CGFloat = 24
    }
}
