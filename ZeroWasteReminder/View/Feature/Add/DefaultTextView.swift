import Combine
import UIKit

public final class DefaultTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        textValueSubject.eraseToAnyPublisher()
    }

    private let maximumNumberOfCharacters: Int
    private let textValueSubject: PassthroughSubject<String, Never>

    public init(maximumNumberOfCharacters: Int = 0) {
        self.maximumNumberOfCharacters = max(0, maximumNumberOfCharacters)
        self.textValueSubject = .init()

        super.init(frame: .zero, textContainer: .none)

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        backgroundColor = .tertiarySystemFill
        tintColor = .accent
        font = .systemFont(ofSize: 16)
        returnKeyType = .done
        isScrollEnabled = false
        textContainerInset = .init(top: 14, left: 8, bottom: 14, right: 8)
        delegate = self

        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor
    }
}

extension DefaultTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0.5
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = .zero
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        textValueSubject.send(textView.text)
    }

    public func textView(
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
