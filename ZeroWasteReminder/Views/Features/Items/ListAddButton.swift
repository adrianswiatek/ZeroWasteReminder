import Combine
import UIKit

public final class ListAddButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never>

    public override init(frame: CGRect) {
        self.tapSubject = .init()
        super.init(frame: frame)
        self.setupView()
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

        let configuration = UIImage.SymbolConfiguration(scale: .large)
        setImage(.fromSymbol(.plus, withConfiguration: configuration), for: .normal)
        setImage(.fromSymbol(.plus, withConfiguration: configuration), for: .highlighted)

        tintColor = .white
        backgroundColor = .accent

        layer.cornerRadius = 26

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            widthAnchor.constraint(equalToConstant: 52)
        ])

        addAction(UIAction { [weak self] _ in self?.tapSubject.send() }, for: .touchUpInside)
    }
}
