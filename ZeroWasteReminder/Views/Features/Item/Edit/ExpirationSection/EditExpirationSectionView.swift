import Combine
import UIKit

public final class EditExpirationSectionView: UIView {
    public var tap: AnyPublisher<TapSource, Never> {
        Publishers.Merge(
            dateButton.tap.map { TapSource.dateButton },
            removeDateButton.tap.map { TapSource.removeDateButton }
        ).eraseToAnyPublisher()
    }

    public var datePickerValue: AnyPublisher<Date, Never> {
        datePicker.value
    }

    private let label: UILabel
    private let stateIndicatorLabel: StateIndicatorLabel
    private let dateButton: ExpirationDateButton
    private let removeDateButton: RemoveExpirationDateButton
    private let datePicker: ExpirationDatePicker

    public init() {
        self.label = .defaultWithText(.localized(.expirationDate))
        self.stateIndicatorLabel = .init()
        self.dateButton = .init(type: .system)
        self.removeDateButton = .init(type: .system)
        self.datePicker = .init()

        super.init(frame: .zero)

        self.setupView()
    }

    public func setState(_ state: RemainingState) {
        stateIndicatorLabel.setState(state)
    }

    public func setExpiration(_ date: Date, _ formattedDate: String) {
        datePicker.setDate(date, animated: false)
        dateButton.setTitle(formattedDate, for: .normal)
    }

    public func setDatePickerVisibility(_ show: Bool) {
        datePicker.setVisibility(show)
    }

    public func setRemoveButtonEnabled(_ isEnabled: Bool) {
        removeDateButton.isEnabled = isEnabled
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
