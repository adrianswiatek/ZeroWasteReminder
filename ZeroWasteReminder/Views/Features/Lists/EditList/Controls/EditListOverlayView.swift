import UIKit

internal final class EditListOverlayView: UIView {
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .accent
    }
}

extension EditListOverlayView: EditListControl {
    internal func setState(to state: EditListComponent.State) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = state == .idle ? 0 : 0.25
        }
    }
}
