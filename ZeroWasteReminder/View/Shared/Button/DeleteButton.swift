import Combine
import UIKit

public final class DeleteButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let tapSubject: PassthroughSubject<Void, Never> = .init()

    private var trashImage: UIImage {
        UIImage.fromSymbol(.trash)
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.expired)
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        self.setupView()
        self.setupTargets()
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width + 24, height: 44)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .tertiarySystemFill

        setImage(trashImage, for: .normal)
        imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)

        setTitle("Delete item", for: .normal)
        setTitleColor(.expired, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 14)
        titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)

        layer.cornerRadius = 8
    }

    private func setupTargets() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc
    private func handleTap() {
        tapSubject.send()
    }
}
