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
        super.willMove(toSuperview: superview)
        self.setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 8

        titleLabel?.font = .systemFont(ofSize: 14, weight: .light)

        backgroundColor = .tertiarySystemFill
        setTitleColor(.label, for: .normal)

        let image = UIImage.fromSymbol(.calendarBadgeMinus).withRenderingMode(.alwaysOriginal).withTintColor(.label)
        setImage(image, for: .normal)

        addAction(UIAction { [weak self] _ in self?.tapSubject.send() }, for: .touchUpInside)
    }
}
