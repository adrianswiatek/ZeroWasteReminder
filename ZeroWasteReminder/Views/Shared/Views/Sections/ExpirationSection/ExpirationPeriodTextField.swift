import UIKit

public final class ExpirationPeriodTextField: UITextField {
    public init(placeholder: String = "") {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override var intrinsicContentSize: CGSize {
        .init(width: 0, height: 48)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 2, left: 10, bottom: 0, right: 15))
    }

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: .init(top: 2, left: 10, bottom: 0, right: 20))
    }

    private func setupView() {
        borderStyle = .none
        backgroundColor = .tertiarySystemFill
        tintColor = .accent
        font = .systemFont(ofSize: 16)
        returnKeyType = .done
        clearButtonMode = .whileEditing

        translatesAutoresizingMaskIntoConstraints = false

        layer.cornerRadius = 8
        layer.borderColor = UIColor.accent.cgColor

        addAction(UIAction { [weak self] _ in self?.layer.borderWidth = 0.5}, for: .editingDidBegin)
        addAction(UIAction { [weak self] _ in self?.layer.borderWidth = 0}, for: .editingDidEnd)
    }
}
