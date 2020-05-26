import Combine
import UIKit

public final class ClearButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never>

    public override var intrinsicContentSize: CGSize {
        .init(width: 32, height: 32)
    }

    public override init(frame: CGRect) {
        self.tapSubject = .init()

        super.init(frame: frame)

        self.setupView()
        self.setupTarget()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(image(), for: .normal)
    }

    private func image() -> UIImage {
        let imageConfiguration = UIImage.SymbolConfiguration(scale: .small)

        return UIImage.fromSymbol(.multiplyCircleFill, withConfiguration: imageConfiguration)
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.tertiaryLabel)
    }

    private func setupTarget() {
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
    }

    @objc
    private func tapped() {
        tapSubject.send()
    }
}
