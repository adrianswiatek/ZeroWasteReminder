import Combine
import UIKit

public final class ItemNameTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let clearButton = ClearButton(type: .system)

    private let valueSubject: PassthroughSubject<String, Never>
    private let sharedDelegateHandler: SharedTextViewDelegateHandler

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.valueSubject = .init()
        self.sharedDelegateHandler = NameTextViewDelegateHandler()
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

        font = .systemFont(ofSize: 16)
        textContainerInset = .init(top: 14, left: 8, bottom: 14, right: 22)

        isScrollEnabled = false
        enablesReturnKeyAutomatically = true
        returnKeyType = .done

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor
    }

    private func layoutClearButton() {
        addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 8),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
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

private extension ItemNameTextView {
    final class NameTextViewDelegateHandler: SharedTextViewDelegateHandler {
        private let maximumNumberOfCharacters: Int = 100

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if text == "\n" {
                textView.endEditing(true)
            }

            if let range = Range<String.Index>(range, in: textView.text), maximumNumberOfCharacters > 0 {
                return textView.text.replacingCharacters(in: range, with: text).count <= maximumNumberOfCharacters
            }

            return true
        }
    }
}
