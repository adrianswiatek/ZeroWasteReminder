import Combine
import UIKit

public final class SearchBarDismissButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private let image: UIImage = {
        let imageConfiguration = UIImage.SymbolConfiguration(scale: .large)
        return UIImage.fromSymbol(.xmark, withConfiguration: imageConfiguration)
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
    }()

    private let tapSubject: PassthroughSubject<Void, Never> = .init()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        setImage(image, for: .normal)

        addAction(.init { [weak self] _ in
            self?.tapSubject.send()
        }, for: .touchUpInside)
    }
}
