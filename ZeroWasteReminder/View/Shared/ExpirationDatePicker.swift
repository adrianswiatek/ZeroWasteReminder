import Combine
import UIKit

public final class ExpirationDatePicker: UIDatePicker {
    public var value: AnyPublisher<Date, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<Date, Never>

    public override init(frame: CGRect) {
        self.valueSubject = .init()

        super.init(frame: frame)

        self.setupUserInterface()
        self.setupTarget()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false
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
