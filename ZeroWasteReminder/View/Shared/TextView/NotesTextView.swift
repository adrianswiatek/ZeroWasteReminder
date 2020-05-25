import Combine
import UIKit

public final class NotesTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<String, Never>
    private let sharedDelegate: SharedTextViewDelegate

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.valueSubject = .init()
        self.sharedDelegate = .init()

        self.subscriptions = []

        super.init(frame: .zero, textContainer: .none)

        self.delegate = sharedDelegate

        self.setupView()
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
        textColor = .label
        font = .systemFont(ofSize: 14)
        textContainerInset = .init(top: 15, left: 8, bottom: 15, right: 8)

        isScrollEnabled = false
        enablesReturnKeyAutomatically = true

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor
    }

    private func bind() {
        sharedDelegate.value
            .subscribe(valueSubject)
            .store(in: &subscriptions)
    }
}
