import UIKit

public final class NewListOverlayView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setState(to state: NewListComponent.State) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = .fromState(state)
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
}

private extension UIColor {
    static func fromState(_ state: NewListComponent.State) -> UIColor {
        switch state {
        case .idle: return UIColor.secondaryLabel.withAlphaComponent(0)
        case .active: return UIColor.secondaryLabel.withAlphaComponent(0.35)
        }
    }
}
