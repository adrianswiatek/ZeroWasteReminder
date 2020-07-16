import Combine
import UIKit

internal final class EditListMixedButton: UIButton {
    internal var addTapped: AnyPublisher<Void, Never> {
        addTappedSubject.eraseToAnyPublisher()
    }

    internal var dismissTapped: AnyPublisher<Void, Never> {
        dismissTappedSubject.eraseToAnyPublisher()
    }

    private let stateSubject: CurrentValueSubject<EditListComponent.State, Never>
    private let addTappedSubject: PassthroughSubject<Void, Never>
    private let dismissTappedSubject: PassthroughSubject<Void, Never>

    private var subscriptions: Set<AnyCancellable>

    internal override init(frame: CGRect) {
        self.stateSubject = .init(.idle)
        self.addTappedSubject = .init()
        self.dismissTappedSubject = .init()
        self.subscriptions = []

        super.init(frame: frame)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    private func bind() {
        stateSubject
            .compactMap { [weak self] in
                self?.backgroundColorAndImageForState($0)
            }
            .sink { [weak self] in
                self?.setBackgroundColor($0.color)
                self?.setImage($0.image)
            }
            .store(in: &subscriptions)
    }

    private func backgroundColorAndImageForState(
        _ state: EditListComponent.State
    ) -> (color: UIColor, image: UIImage) {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)

        switch state {
        case .idle:
            return (.accent, .fromSymbol(.textBadgePlus, withConfiguration: symbolConfiguration))
        case .active:
            return (.expired, .fromSymbol(.xmark, withConfiguration: symbolConfiguration))
        }
    }

    private func setImage(_ image: UIImage) {
        setImage(image, for: .normal)
        setImage(image.withColor(UIColor.white.withAlphaComponent(0.35)), for: .highlighted)
    }

    private func setBackgroundColor(_ color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.backgroundColor = color
        }
    }

    @objc
    private func handleTap() {
        switch stateSubject.value {
        case .idle:
            addTappedSubject.send()
        case .active:
            dismissTappedSubject.send()
        }
    }
}

extension EditListMixedButton: EditListControl {
    internal func setState(to state: EditListComponent.State) {
        stateSubject.send(state)
    }
}
