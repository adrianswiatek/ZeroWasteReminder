import Combine
import UIKit

public final class NameTextView: UITextView {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<String, Never>
    private let sharedDelegate: SharedTextViewDelegate

    public init(maximumNumberOfCharacters: Int = 0) {
        self.valueSubject = .init()
        self.sharedDelegate = TextViewDelegate(maximumNumberOfCharacters)

        super.init(frame: .zero, textContainer: .none)

        self.delegate = self.sharedDelegate
        self.setupView()
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
        textContainerInset = .init(top: 14, left: 8, bottom: 14, right: 8)

        isScrollEnabled = false
        enablesReturnKeyAutomatically = true
        returnKeyType = .done

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor
    }
}

private extension NameTextView {
    class TextViewDelegate: SharedTextViewDelegate {
        private let maximumNumberOfCharacters: Int

        init(_ maximumNumberOfCharacters: Int) {
            self.maximumNumberOfCharacters = max(0, maximumNumberOfCharacters)
        }

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
