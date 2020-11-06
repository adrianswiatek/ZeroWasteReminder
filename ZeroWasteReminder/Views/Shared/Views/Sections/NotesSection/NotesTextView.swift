import Combine
import UIKit

public final class NotesTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let clearButton = ClearButton(type: .system)

    private let valueSubject: PassthroughSubject<String, Never>
    private let sharedDelegateHandler: SharedTextViewDelegateHandler

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.valueSubject = .init()
        self.sharedDelegateHandler = .init()
        self.subscriptions = []

        super.init(frame: .zero, textContainer: .none)

        self.delegate = sharedDelegateHandler

        self.setupView()
        self.layoutClearButton()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = .tertiarySystemFill
        tintColor = .accent

        typingAttributes = [
            .paragraphStyle: paragraphStyle(),
            .font: UIFont.systemFont(ofSize: 14, weight: .light),
            .foregroundColor: UIColor.label
        ]

        textContainerInset = .init(top: 15, left: 8, bottom: 15, right: 22)

        isScrollEnabled = false
        enablesReturnKeyAutomatically = true

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor
    }

    private func layoutClearButton() {
        addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor, constant: 8
            ),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func paragraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        return paragraphStyle
    }

    private func bind() {
        sharedDelegateHandler.value
            .sink { [weak self] in self?.valueSubject.send($0) }
            .store(in: &subscriptions)

        clearButton.tap
            .sink { [weak self] in self?.text = "" }
            .store(in: &subscriptions)

        Publishers.CombineLatest(sharedDelegateHandler.value, sharedDelegateHandler.isActive)
            .sink { [weak self] in self?.clearButton.isHidden = !($0.0.count > 0 && $0.1) }
            .store(in: &subscriptions)
    }
}
