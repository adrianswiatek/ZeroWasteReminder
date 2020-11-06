import Combine
import UIKit

internal final class EditListConfirmButton: UIButton {
    internal var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never>

    internal override init(frame: CGRect) {
        self.tapSubject = .init()
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        backgroundColor = .accent

        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image: UIImage = .fromSymbol(.checkmark, withConfiguration: symbolConfiguration)

        setImage(image, for: .normal)
        setImage(image.withColor(UIColor.white.withAlphaComponent(0.35)), for: .highlighted)

        addAction(UIAction { [weak self] _ in self?.tapSubject.send() }, for: .touchUpInside)
    }

    private func show() {
        alpha = 1
        transform = .identity
    }

    private func hide() {
        alpha = 0
        transform = .init(scaleX: 0.1, y: 0.1)
    }
}

extension EditListConfirmButton: EditListControl {
    internal func setState(to state: EditListComponent.State) {
        UIView.animate(
            withDuration: 0.75,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .curveEaseOut,
            animations: { self.action(for: state)() }
        )
    }

    private func action(for state: EditListComponent.State) -> () -> Void {
        switch state {
        case .active(let editing) where editing: return show
        default: return hide
        }
    }
}
