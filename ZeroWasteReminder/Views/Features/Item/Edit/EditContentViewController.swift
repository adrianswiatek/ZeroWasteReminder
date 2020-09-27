import Combine
import UIKit

public final class EditContentViewController: UIViewController {
    private let itemNameSectionView: ItemNameSectionView
    private let notesSectionView: NotesSectionView
    private let alarmSectionView: AlarmSectionView

    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let stateIndicatorLabel = StateIndicatorLabel()
    private let dateButton: ExpirationDateButton = .init(type: .system)
    private let removeDateButton: RemoveExpirationDateButton = .init(type: .system)
    private let datePicker = ExpirationDatePicker()

    private let photosSectionView: PhotosSectionView
    private let actionsSectionView: ActionsSectionView

    private let viewModel: EditItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.itemNameSectionView = .init()
        self.notesSectionView = .init()
        self.alarmSectionView = .init()
        self.photosSectionView = .init(viewModel: viewModel.photosViewModel)
        self.actionsSectionView = .init()

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

        view.addSubview(itemNameSectionView)
        NSLayoutConstraint.activate([
            itemNameSectionView.topAnchor.constraint(
                equalTo: view.topAnchor, constant: Metrics.betweenSectionsPadding
            ),
            itemNameSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemNameSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(
                equalTo: itemNameSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            expirationDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(stateIndicatorLabel)
        NSLayoutConstraint.activate([
            stateIndicatorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateIndicatorLabel.centerYAnchor.constraint(equalTo: expirationDateLabel.centerYAnchor)
        ])

        view.addSubview(removeDateButton)
        NSLayoutConstraint.activate([
            removeDateButton.topAnchor.constraint(
                equalTo: expirationDateLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            removeDateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            removeDateButton.heightAnchor.constraint(equalToConstant: Metrics.controlsHeight),
            removeDateButton.widthAnchor.constraint(equalToConstant: Metrics.controlsHeight)
        ])

        view.addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.leadingAnchor.constraint(
                equalTo: removeDateButton.trailingAnchor, constant: Metrics.insideSectionPadding
            ),
            dateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateButton.centerYAnchor.constraint(equalTo: removeDateButton.centerYAnchor),
            dateButton.heightAnchor.constraint(equalTo: removeDateButton.heightAnchor)
        ])

        view.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        view.addSubview(notesSectionView)
        NSLayoutConstraint.activate([
            notesSectionView.topAnchor.constraint(
                equalTo: datePicker.bottomAnchor, constant: Metrics.betweenSectionsPadding),
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

        view.addSubview(photosSectionView)
        NSLayoutConstraint.activate([
            photosSectionView.topAnchor.constraint(
                equalTo: alarmSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            photosSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photosSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(actionsSectionView)
        NSLayoutConstraint.activate([
            actionsSectionView.topAnchor.constraint(
                equalTo: photosSectionView.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            actionsSectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionsSectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            actionsSectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func bind() {
        dateButton.tap
            .sink { [weak self] in
                self?.viewModel.toggleExpirationDatePicker()
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        removeDateButton.tap
            .sink { [weak self] in
                self?.viewModel.setExpirationDate(nil)
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

        datePicker.value
            .sink { [weak self] in self?.viewModel.setExpirationDate($0) }
            .store(in: &subscriptions)

        itemNameSectionView.itemName
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesSectionView.notes
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.isRemoveDateButtonEnabled
            .assign(to: \.isEnabled, on: removeDateButton)
            .store(in: &subscriptions)

        viewModel.$name
            .sink { [weak self] in self?.itemNameSectionView.setText($0) }
            .store(in: &subscriptions)

        viewModel.$notes
            .sink { [weak self] in self?.notesSectionView.setText($0) }
            .store(in: &subscriptions)

        viewModel.expirationDate
            .sink { [weak self] in
                self?.datePicker.setDate($0.date, animated: false)
                self?.dateButton.setTitle($0.formatted, for: .normal)
            }
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
        static let controlsHeight: CGFloat = 44
        static let betweenSectionsPadding: CGFloat = 16
        static let insideSectionPadding: CGFloat = 8
    }
}
