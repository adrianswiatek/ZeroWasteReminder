import Combine
import UIKit

public final class SearchBarViewController: UIView {
    private let backgroundView: UIView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .accent
        $0.layer.shadowOffset = .init(width: 0, height: 5)
        $0.layer.shadowOpacity = 0.1
    }

    private let statusBarBackgroundView: UIView = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .accent
    }

    private let textField: UITextField = SearchBarTextField()
    private let dismissButton: SearchBarDismissButton = .init()

    private var subscriptions: Set<AnyCancellable>

    public init() {
        self.subscriptions = []

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 56)
        ])

        addSubview(statusBarBackgroundView)
        NSLayoutConstraint.activate([
            statusBarBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            statusBarBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusBarBackgroundView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor),
            statusBarBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundView.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16
            ),
            dismissButton.centerYAnchor.constraint(
                equalTo: backgroundView.centerYAnchor
            )
        ])

        backgroundView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: dismissButton.trailingAnchor, constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16
            ),
            textField.centerYAnchor.constraint(
                equalTo: dismissButton.centerYAnchor
            ),
            textField.heightAnchor.constraint(
                equalToConstant: 36
            )
        ])
    }

    private func bind() {
        dismissButton.tap
            .sink { print("Dismiss button tapped.") }
            .store(in: &subscriptions)
    }
}
