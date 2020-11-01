import Combine
import UIKit

public final class ActionButton: UIButton {
    public var tap: AnyPublisher<Void, Never> {
        tapSubject.eraseToAnyPublisher()
    }

    private var iconImage: UIImage?
    private var text: String = ""
    private var foregroundColor: UIColor = .label

    private let tapSubject: PassthroughSubject<Void, Never> = .init()

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        self.setupView()
        self.setupTargets()
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: super.intrinsicContentSize.width + 24, height: 44)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .tertiarySystemFill

        iconImage.map {
            setImage($0.withRenderingMode(.alwaysOriginal).withTintColor(foregroundColor), for: .normal)
            imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        }

        setTitle(text, for: .normal)
        setTitleColor(foregroundColor, for: .normal)
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

public extension ActionButton {
    static var remove: ActionButton {
        .custom(image: .fromSymbol(.trash), text: .localized(.removeItem), color: .expired)
    }

    static var move: ActionButton {
        .custom(image: .fromSymbol(.arrowRightArrowLeft), text: .localized(.moveItem), color: .label)
    }

    static func custom(image: UIImage, text: String, color: UIColor) -> ActionButton {
        let button = ActionButton(type: .system)
        button.iconImage = image
        button.text = text
        button.foregroundColor = color
        return button
    }
}
