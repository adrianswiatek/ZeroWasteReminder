import Combine
import UIKit

public final class SearchBarViewController: UIViewController {
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

        super.init(nibName: nil, bundle: nil)

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
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 56)
        ])

        view.addSubview(statusBarBackgroundView)
        NSLayoutConstraint.activate([
            statusBarBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBarBackgroundView.bottomAnchor.constraint(equalTo: backgroundView.topAnchor),
            statusBarBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        backgroundView.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16
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
                equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16
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
