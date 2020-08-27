import Combine
import UIKit

public final class EditContentViewController: UIViewController {
    private let nameLabel: UILabel = .defaultWithText("Item name")
    private let nameTextView = NameTextView()

    private let expirationDateLabel: UILabel = .defaultWithText("Expiration date")
    private let stateIndicatorLabel = StateIndicatorLabel()
    private let dateButton: ExpirationDateButton = .init(type: .system)
    private let removeDateButton: RemoveExpirationDateButton = .init(type: .system)
    private let datePicker = ExpirationDatePicker()

    private let notesLabel: UILabel = .defaultWithText("Notes")
    private let notesTextView = NotesTextView()

    private let photosLabel: UILabel = .defaultWithText(.localized(.photos))
    private let photosViewController: PhotosViewController

    private let actionsLabel: UILabel = .defaultWithText("Actions")
    private let moveButton: ActionButton = .move
    private let removeButton: ActionButton = .remove

    private let viewModel: EditViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.photosViewController = .init(viewModel: viewModel.photosViewModel)

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

        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Metrics.betweenSectionsPadding),
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

        view.addSubview(expirationDateLabel)
        NSLayoutConstraint.activate([
            expirationDateLabel.topAnchor.constraint(
                equalTo: nameTextView.bottomAnchor, constant: Metrics.betweenSectionsPadding
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

        view.addSubview(notesLabel)
        NSLayoutConstraint.activate([
            notesLabel.topAnchor.constraint(
                equalTo: datePicker.bottomAnchor, constant: Metrics.betweenSectionsPadding
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
            photosViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.addSubview(actionsLabel)
        NSLayoutConstraint.activate([
            actionsLabel.topAnchor.constraint(
                equalTo: photosViewController.view.bottomAnchor, constant: Metrics.betweenSectionsPadding
            ),
            actionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        view.addSubview(removeButton)
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(
                equalTo: actionsLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            removeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            removeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(moveButton)
        NSLayoutConstraint.activate([
            moveButton.topAnchor.constraint(
                equalTo: actionsLabel.bottomAnchor, constant: Metrics.insideSectionPadding
            ),
            moveButton.leadingAnchor.constraint(
                equalTo: removeButton.trailingAnchor, constant: Metrics.insideSectionPadding
            ),
            moveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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

        removeButton.tap
            .sink { [weak self] in
                self?.viewModel.requestSubject.send(.removeCurrentItem)
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        moveButton.tap
            .sink { [weak self] in
                self?.viewModel.requestSubject.send(.moveCurrentItem)
                self?.view.endEditing(true)
            }
            .store(in: &subscriptions)

        datePicker.value
            .sink { [weak self] in self?.viewModel.setExpirationDate($0) }
            .store(in: &subscriptions)

        nameTextView.value
            .assign(to: \.name, on: viewModel)
            .store(in: &subscriptions)

        notesTextView.value
            .assign(to: \.notes, on: viewModel)
            .store(in: &subscriptions)

        viewModel.isRemoveDateButtonEnabled
            .assign(to: \.isEnabled, on: removeDateButton)
            .store(in: &subscriptions)

        viewModel.$name
            .sink { [weak self] in self?.nameTextView.text = $0 }
            .store(in: &subscriptions)

        viewModel.$notes
            .sink { [weak self] in self?.notesTextView.text = $0 }
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
