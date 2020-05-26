import Combine
import UIKit

public final class ExpirationDateButton: UIButton {
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

        imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)

        titleLabel?.font = .systemFont(ofSize: 14, weight: .light)

        backgroundColor = .tertiarySystemFill
        setTitleColor(.label, for: .normal)

        let image = UIImage.fromSymbol(.calendar).withRenderingMode(.alwaysOriginal).withTintColor(.label)
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
