import UIKit

public final class AddItemTextField: UITextField {
    public init(placeholder: String) {
        super.init(frame: .zero)

        self.placeholder = placeholder
        self.borderStyle = .roundedRect
        self.backgroundColor = .init(white: 0.95, alpha: 1)
        self.font = .systemFont(ofSize: 16)
        self.translatesAutoresizingMaskIntoConstraints = false
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
}
