import Combine
import UIKit

public final class ExpirationDatePicker: UIDatePicker {
    public var value: AnyPublisher<Date, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    public override var isHidden: Bool {
        didSet {
            heightConstraint.constant = isHidden ? 0 : height
        }
    }

    private let valueSubject: PassthroughSubject<Date, Never>

    private var heightConstraint: NSLayoutConstraint!
    private var height: CGFloat!

    public override init(frame: CGRect) {
        self.valueSubject = .init()

        super.init(frame: frame)

        self.height = bounds.height
        self.heightConstraint = heightAnchor.constraint(equalToConstant: height)

        self.setupUserInterface()
        self.setupTarget()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    public func setVisibility(_ show: Bool) {
        guard isHidden == show else { return }

        if let superview = superview {
            UIView.transition(with: superview, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                self.isHidden = !show
            })
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                superview.layoutIfNeeded()
            })
        } else {
            isHidden = !show
        }
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
        datePickerMode = .date
    }

    private func setupTarget() {
        addTarget(self, action: #selector(handleDatePickerValueChanged), for: .valueChanged)
    }

    @objc
    private func handleDatePickerValueChanged(_ sender: UIDatePicker) {
        valueSubject.send(sender.date)
    }
}
