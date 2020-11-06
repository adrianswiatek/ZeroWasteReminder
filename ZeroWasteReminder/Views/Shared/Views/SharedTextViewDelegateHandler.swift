import Combine
import UIKit

public class SharedTextViewDelegateHandler: NSObject, UITextViewDelegate {
    public var value: AnyPublisher<String, Never> {
        valueSubject.eraseToAnyPublisher()
    }

    public var isActive: AnyPublisher<Bool, Never> {
        isActiveSubject.eraseToAnyPublisher()
    }

    private let valueSubject: PassthroughSubject<String, Never> = .init()
    private let isActiveSubject: CurrentValueSubject<Bool, Never> = .init(false)

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0.5
        isActiveSubject.value = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = .zero
        isActiveSubject.value = false
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        valueSubject.send(textView.text)
    }
}
