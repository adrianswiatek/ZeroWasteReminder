import Combine
import UIKit

public final class SearchBarTextField: UITextField {
    public var searchTerm: AnyPublisher<String, Never> {
        searchTermSubject.eraseToAnyPublisher()
    }

    private let searchTermSubject: CurrentValueSubject<String, Never> = .init("")

    public init() {
        super.init(frame: .zero)
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 18, dy: 0).offsetBy(dx: -10, dy: 0)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.insetBy(dx: 18, dy: 0).offsetBy(dx: -10, dy: 0)
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self

        tintColor = .accent
        backgroundColor = .systemBackground

        placeholder = .localized(.search)
        returnKeyType = .search
        clearButtonMode = .whileEditing

        layer.cornerRadius = 8

        setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }
}

extension SearchBarTextField: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text.map { searchTermSubject.send($0) }
    }
}
