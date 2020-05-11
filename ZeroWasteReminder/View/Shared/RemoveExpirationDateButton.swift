import Combine
import UIKit

public final class RemoveExpirationDateButton: UIButton {
    public override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.35 }
    }

    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never> = .init()

    public override func willMove(toSuperview newSuperview: UIView?) {
        setupView()
        setupTargets()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 8

        titleLabel?.font = .systemFont(ofSize: 14, weight: .light)

        backgroundColor = .tertiarySystemFill
        setTitleColor(.label, for: .normal)

        let image = UIImage.calendarMinus.withRenderingMode(.alwaysOriginal).withTintColor(.label)
        setImage(image, for: .normal)
    }

    private func setupTargets() {
        addTarget(self, action: #selector(handleDateButtonTap), for: .touchUpInside)
    }

    @objc
    private func handleDateButtonTap() {
        tapSubject.send()
    }
}
