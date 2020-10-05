import Combine
import UIKit

public final class AlertDateCell: UITableViewCell {
    private let isPressedSubject: CurrentValueSubject<Bool, Never>
    private var subscriptions: Set<AnyCancellable>

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.isPressedSubject = .init(false)
        self.subscriptions = []
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        setupColors()
        setupTrailingPart()
    }

    public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.isPressedSubject.send(highlighted)
    }

    public func set(_ viewModel: AlertDateCellViewModel) {
        Publishers.CombineLatest3(viewModel.$date, viewModel.$isCalendarShown, isPressedSubject)
            .sink(receiveValue: stateChanged)
            .store(in: &subscriptions)
    }

    private func setupView() {
        tintColor = .label
        backgroundColor = .clear

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = backgroundColor()
    }

    private func stateChanged(_ date: Date?, _ isCalendarShown: Bool, _ isPressed: Bool) {
        setupLabel(with: date)
        setupColors(isCalendarShown, isPressed)
        setupTrailingPart(isCalendarShown)
    }

    private func setupLabel(with date: Date?) {
        textLabel?.text = date.map {
            DateFormatter.longDate.string(from: $0)
        } ?? .localized(.date)
    }

    private func setupColors(_ isCalendarShown: Bool = false, _ isPressed: Bool = false) {
        textLabel?.textColor = textColor(isCalendarShown)
        selectedBackgroundView?.backgroundColor = backgroundColor(isCalendarShown, isPressed)
    }

    private func textColor(_ isCalendarShown: Bool = false) -> UIColor {
        switch (isSelected, isCalendarShown) {
        case (true, true): return .expired
        case (true, false): return .label
        case (false, _): return .secondaryLabel
        }
    }

    private func backgroundColor(_ isCalendarShown: Bool = false, _ isPressed: Bool = false) -> UIColor {
        switch (isCalendarShown, isPressed) {
        case (true, true): return .tertiarySystemBackground
        case (false, false): return .clear
        default: return .secondarySystemBackground
        }
    }

    private func setupTrailingPart(_ isCalendarShown: Bool = false) {
        accessoryType = isSelected && !isCalendarShown ? .checkmark : .none
        detailTextLabel?.text = isSelected && isCalendarShown ? "Tap to confirm" : ""
    }
}
