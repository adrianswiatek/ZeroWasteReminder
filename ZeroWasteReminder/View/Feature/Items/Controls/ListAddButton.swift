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
        
        self.setupView()
        self.setupActions()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func setVisibility(_ isVisible: Bool) {
        guard let superview = superview else { return }
        UIView.transition(with: superview, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.isHidden = !isVisible
        })
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        setImage(.fromSymbol(.plus), for: .normal)
        setImage(.fromSymbol(.plus), for: .highlighted)

        tintColor = .white
        backgroundColor = .accent

        layer.cornerRadius = 26
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .init(width: 0, height: 2)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func setupActions() {
        addTarget(self, action: #selector(handleTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(handleTouchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(handleTouchDown), for: .touchDown)
    }

    @objc
    private func handleTouchUpInside() {
        animateButton(action: animateTouchUp)
        tapSubject.send()
    }

    @objc
    private func handleTouchUpOutside() {
        animateButton(action: animateTouchUp)
    }

    @objc
    private func handleTouchDown() {
        animateButton {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.75)
            self.imageView?.transform = .init(scaleX: 0.9, y: 0.9)
            self.transform = .init(scaleX: 0.9, y: 0.9)
            self.layer.shadowRadius = 1
        }
    }

    private func animateTouchUp()  {
        self.backgroundColor = self.backgroundColor?.withAlphaComponent(1)
        self.imageView?.transform = .identity
        self.transform = .identity
        self.layer.shadowRadius = 3
    }

    private func animateButton(action: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.125,
            delay: 0,
            usingSpringWithDamping: 10,
            initialSpringVelocity: 0,
            options: [],
            animations: action
        )
    }
}
