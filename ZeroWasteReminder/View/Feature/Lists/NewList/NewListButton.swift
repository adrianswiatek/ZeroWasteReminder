import Combine
import UIKit

public final class NewListButton: UIButton {
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

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0.85
        backgroundColor = .accent
        tintColor = .white
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        layer.cornerRadius = 26
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .init(width: 0, height: 2)

        addTarget(self, action: #selector(handleTap), for: .touchUpInside)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 52),
            widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    public func setState(to state: NewListComponent.State) {
        let (color, image) = backgroundColorAndImageForState(state)
        backgroundColor = color
        setImage(image, for: .normal)
    }

    private func backgroundColorAndImageForState(
        _ state: NewListComponent.State
    ) -> (UIColor, UIImage) {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)

        switch state {
        case .idle:
            return (.accent, .fromSymbol(.textBadgePlus, withConfiguration: symbolConfiguration))
        case .active:
            return (.expired, .fromSymbol(.xmark, withConfiguration: symbolConfiguration))
        }
    }

    @objc
    private func handleTap() {
        tapSubject.send()
    }
}
