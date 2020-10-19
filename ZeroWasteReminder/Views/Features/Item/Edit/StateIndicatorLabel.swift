import UIKit

public final class StateIndicatorLabel: UILabel {
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.setupView()
    }

    public func setState(_ state: RemainingState) {
        let settings: Settings = .fromState(state)
        text = settings.formattedState
        textColor = settings.color
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        font = .systemFont(ofSize: 14, weight: .medium)
        textAlignment = .right
        backgroundColor = .systemBackground
        clipsToBounds = true
        layer.cornerRadius = 8
    }
}

private extension StateIndicatorLabel {
    struct Settings {
        let formattedState: String
        let color: UIColor

        init(formattedState: String, color: UIColor) {
            self.formattedState = formattedState
            self.color = color
        }

        static func fromState(_ state: RemainingState) -> Settings {
            switch state {
            case .notDefined:
                return .init(formattedState: "Date not defined", color: .tertiaryLabel)
            case .expired:
                return .init(formattedState: "Expired", color: .expired)
            case .almostExpired:
                return .init(formattedState: "Almost expired", color: .almostExpired)
            case let .valid(value, component):
                let formattedComponent = component.format(forValue: value)
                return .init(formattedState: "Valid (\(formattedComponent))", color: .valid)
            }
        }
    }
}
