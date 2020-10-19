import Combine
import UIKit

public final class EditExpirationSectionView: UIView {
    private let label: UILabel
    private let stateIndicatorLabel: StateIndicatorLabel
    private let dateButton: ExpirationDateButton
    private let removeDateButton: RemoveExpirationDateButton
    private let datePicker: ExpirationDatePicker

    private let viewModel: EditItemViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditItemViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        self.label = .defaultWithText(.localized(.expirationDate))
        self.stateIndicatorLabel = .init()
        self.dateButton = .init(type: .system)
        self.removeDateButton = .init(type: .system)
        self.datePicker = .init()

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(stateIndicatorLabel)
        NSLayoutConstraint.activate([
            stateIndicatorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            stateIndicatorLabel.centerYAnchor.constraint(equalTo: label.centerYAnchor)
        ])

        addSubview(removeDateButton)
        NSLayoutConstraint.activate([
            removeDateButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Metrics.spacing),
            removeDateButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            removeDateButton.heightAnchor.constraint(equalToConstant: Metrics.sideValue),
            removeDateButton.widthAnchor.constraint(equalToConstant: Metrics.sideValue)
        ])

        addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.leadingAnchor.constraint(
                equalTo: removeDateButton.trailingAnchor, constant: Metrics.spacing
            ),
            dateButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateButton.centerYAnchor.constraint(equalTo: removeDateButton.centerYAnchor),
            dateButton.heightAnchor.constraint(equalTo: removeDateButton.heightAnchor)
        ])

        addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func bind() {
        viewModel.expirationDate
            .sink { [weak self] in
                self?.datePicker.setDate($0.date, animated: false)
                self?.dateButton.setTitle($0.formatted, for: .normal)
            }
            .store(in: &subscriptions)

        viewModel.isExpirationDateVisible
            .sink { [weak self] in self?.datePicker.setVisibility($0) }
            .store(in: &subscriptions)

        viewModel.isRemoveDateButtonEnabled
            .assign(to: \.isEnabled, on: removeDateButton)
            .store(in: &subscriptions)

        viewModel.state
            .sink { [weak self] in self?.stateIndicatorLabel.setState($0) }
            .store(in: &subscriptions)

        dateButton.tap
            .sink { [weak self] in self?.viewModel.toggleExpirationDatePicker() }
            .store(in: &subscriptions)

        removeDateButton.tap
            .sink { [weak self] in self?.viewModel.setExpirationDate(nil) }
            .store(in: &subscriptions)

        datePicker.value
            .sink { [weak self] in self?.viewModel.setExpirationDate($0) }
            .store(in: &subscriptions)
    }
}

public extension EditExpirationSectionView {
    enum TapSource {
        case dateButton
        case removeDateButton
    }
}

private extension EditExpirationSectionView {
    enum Metrics {
        static let sideValue: CGFloat = 44
        static let spacing: CGFloat = 8
    }
}
