import Combine
import UIKit

public final class ExpirationDatePicker: UIDatePicker {
    public var value: AnyPublisher<Date, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<Date, Never>
    private var heightConstraint: NSLayoutConstraint!

    public override init(frame: CGRect) {
        self.valueSubject = .init()

        super.init(frame: frame)

        self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)

        self.setupView()
        self.setupTarget()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    public func setVisibility(_ show: Bool) {
        heightConstraint.constant = show ? intrinsicContentSize.height : .zero
        guard let window = window else { return }

        UIView.animate(withDuration: 0.3) {
            window.layoutIfNeeded()
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.isHidden = !show
        })
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint.isActive = true
        datePickerMode = .date

        if #available(iOS 13.4, *) {
            preferredDatePickerStyle = .wheels
        }
    }

    private func setupTarget() {
        addAction(UIAction { [weak self] in
            guard let datePicker = $0.sender as? UIDatePicker else { return }
            self?.valueSubject.send(datePicker.date)
        }, for: .touchUpInside)

        addTarget(self, action: #selector(handleDatePickerValueChanged), for: .valueChanged)
    }

    @objc
    private func handleDatePickerValueChanged(_ sender: UIDatePicker) {
        valueSubject.send(sender.date)
    }
}
