import Combine
import UIKit

public final class NotesSectionView: UIView {
    public var notes: AnyPublisher<String, Never> {
        textView.value
    }

    private let label: UILabel
    private let textView: NotesTextView

    public init() {
        self.label = .defaultWithText(.localized(.notes))
        self.textView = .init()

        super.init(frame: .zero)

        self.setupView()
    }

    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
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

private extension NotesSectionView {
    enum Metrics {
        static let spacing: CGFloat = 8
    }
}
