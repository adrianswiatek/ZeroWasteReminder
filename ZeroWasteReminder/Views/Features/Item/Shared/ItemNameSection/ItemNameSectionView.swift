import Combine
import UIKit

public final class ItemNameSectionView: UIView {
    public var itemName: AnyPublisher<String, Never> {
        textView.value
    }

    private let label: UILabel
    private let textView: ItemNameTextView

    public init() {
        self.label = .defaultWithText(.localized(.itemName))
        self.textView = .init()

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    public func setText(_ text: String) {
        textView.text = text
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: label.bottomAnchor, constant: Metrics.spacing
            ),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: Metrics.spacing
            ),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

private extension ItemNameSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
