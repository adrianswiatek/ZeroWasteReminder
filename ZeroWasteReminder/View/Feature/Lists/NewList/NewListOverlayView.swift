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
            self.alpha = state == .idle ? 0 : 0.5
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .accent
    }
}
