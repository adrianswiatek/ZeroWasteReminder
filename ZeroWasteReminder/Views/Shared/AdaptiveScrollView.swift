import Combine
import UIKit

public final class AdaptiveScrollView: UIScrollView {
    public var additionalOffset: CGFloat

    private let notificationCenter: NotificationCenter
    private var subscriptions: Set<AnyCancellable>

    public override init(frame: CGRect) {
        self.notificationCenter = .default
        self.subscriptions = []
        self.additionalOffset = 0

        super.init(frame: frame)

        self.setupView()
        self.registerKeyboardObservers()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func registerKeyboardObservers() {
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { UIEdgeInsets(top: 0, left: 0, bottom: $0.height, right: 0)}
            .sink { [weak self] in self?.adjustInsets($0) }
            .store(in: &subscriptions)

        notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.adjustInsets(.zero) }
            .store(in: &subscriptions)
    }

    private func adjustInsets(_ insets: UIEdgeInsets) {
        contentInset = insets
        contentInset.bottom += additionalOffset

        verticalScrollIndicatorInsets = insets
        verticalScrollIndicatorInsets.bottom += additionalOffset
    }
}
