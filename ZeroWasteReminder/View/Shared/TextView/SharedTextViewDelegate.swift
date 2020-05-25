import Combine
import UIKit

public class SharedTextViewDelegate: NSObject, UITextViewDelegate {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<String, Never> = .init()

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0.5
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = .zero
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        valueSubject.send(textView.text)
    }
}
