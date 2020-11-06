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
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true
        setImage(image(), for: .normal)
        addAction(UIAction { [weak self] _ in self?.tapSubject.send() }, for: .touchUpInside)
    }

    private func image() -> UIImage {
        let imageConfiguration = UIImage.SymbolConfiguration(scale: .small)

        return UIImage.fromSymbol(.multiplyCircleFill, withConfiguration: imageConfiguration)
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.tertiaryLabel)
    }
}
