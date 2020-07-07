import Combine
import UIKit

public final class NewListView: UIView {
    public var state: AnyPublisher<State, Never> {
        stateSubject.removeDuplicates().eraseToAnyPublisher()
    }

    private lazy var newListButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(handleNewListButtonTap), for: .touchUpInside)
        return button
    }()

    private let stateSubject: CurrentValueSubject<State, Never>
    private var subscriptions: Set<AnyCancellable>

    public override init(frame: CGRect) {
        self.stateSubject = .init(.button)
        self.subscriptions = []

        super.init(frame: frame)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 0.85
        backgroundColor = .accent

        layer.cornerRadius = 26
        layer.shadowOpacity = 0.5
        layer.shadowOffset = .init(width: 0, height: 2)

        addSubview(newListButton)
        NSLayoutConstraint.activate([
            newListButton.topAnchor.constraint(equalTo: topAnchor),
            newListButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            newListButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            newListButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            newListButton.heightAnchor.constraint(equalToConstant: 52),
            newListButton.widthAnchor.constraint(equalToConstant: 52)
        ])
    }

    private func bind() {
        state.sink { [weak self] in self?.setState(to: $0) }.store(in: &subscriptions)
    }

    private func setState(to state: State) {
        let (color, image) = backgroundColorAndImageForState(state)
        backgroundColor = color
        newListButton.setImage(image, for: .normal)
    }

    private func backgroundColorAndImageForState(_ state: State) -> (UIColor, UIImage) {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)

        switch state {
        case .button:
            return (.accent, .fromSymbol(.textBadgePlus, withConfiguration: symbolConfiguration))
        case .textField:
            return (.expired, .fromSymbol(.xmark, withConfiguration: symbolConfiguration))
        }
    }

    @objc
    private func handleNewListButtonTap() {
        stateSubject.value = stateSubject.value.toggled()
    }
}

extension NewListView {
    public enum State {
        case button
        case textField

        public func toggled() -> State {
            self == .button ? .textField : .button
        }
    }
}
