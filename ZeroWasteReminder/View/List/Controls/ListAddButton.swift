import Combine
import UIKit

public final class ListAddButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never>

    public init() {
        self.tapSubject = .init()
        super.init(frame: .zero)
        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false

        setImage(UIImage(systemName: "plus"), for: .normal)
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)

        tintColor = UIColor.black.withAlphaComponent(0.75)
        backgroundColor = .systemPurple

        layer.cornerRadius = 26

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    @objc
    private func handleTouchUpInside() {
        animateButton {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
            self.imageView?.transform = .identity
            self.transform = .identity
        }
        tapSubject.send()
    }

    @objc
    private func handleTouchDown() {
        animateButton {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.75)
            self.imageView?.transform = .init(scaleX: 0.9, y: 0.9)
            self.transform = .init(scaleX: 0.9, y: 0.9)
        }
    }

    private func animateButton(action: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            usingSpringWithDamping: 10,
            initialSpringVelocity: 0,
            options: [],
            animations: action
        )
    }
}
