import Combine
import UIKit

public final class NotesTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false

        let image = UIImage.multiply.withRenderingMode(.alwaysOriginal).withTintColor(.tertiaryLabel)
        button.setImage(image, for: .normal)
        button.imageView?.transform.scaledBy(x: 0.25, y: 0.25)

        button.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return button
    }()

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
        font = .systemFont(ofSize: 14, weight: .light)

        textContainerInset = .init(top: 15, left: 8, bottom: 15, right: 28)

        clipsToBounds = false
        isScrollEnabled = false
        enablesReturnKeyAutomatically = true

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor

        addSubview(clearButton)
        NSLayoutConstraint.activate([
            clearButton.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.heightAnchor.constraint(equalToConstant: 22),
            clearButton.widthAnchor.constraint(equalToConstant: 22)
        ])

        superview?.bringSubviewToFront(clearButton)
    }

    private func bind() {
        sharedDelegate.value
            .subscribe(valueSubject)
            .store(in: &subscriptions)

        Publishers.CombineLatest(sharedDelegate.value, sharedDelegate.isActive)
            .sink { [weak self] in self?.clearButton.isHidden = !($0.0.count > 0 && $0.1) }
            .store(in: &subscriptions)
    }

    @objc
    private func clearButtonTapped(_ sender: UIButton) {
        text = ""
    }
}
