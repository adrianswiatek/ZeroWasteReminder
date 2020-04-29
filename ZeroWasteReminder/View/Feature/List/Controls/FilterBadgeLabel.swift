import UIKit

public final class FilterBadgeLabel: UILabel {
    public override var text: String? {
        get {
            super.text
        }
        set {
            super.text = newValue
            self.backgroundColor = newValue?.isEmpty == true ? .clear : .white
        }
    }

    public init() {
        super.init(frame: .zero)

        self.translatesAutoresizingMaskIntoConstraints = false

        self.textAlignment = .center
        self.font = .systemFont(ofSize: 12, weight: .semibold)

        self.textColor = .accent
        self.backgroundColor = .white

        self.clipsToBounds = true
        self.layer.cornerRadius = 7.5
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setVisibility(_ isVisible: Bool) {
        isHidden = !isVisible
    }
}
