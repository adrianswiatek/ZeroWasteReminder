import Combine
import UIKit

public final class ExpirationDateView: UIView {
    private lazy var yearTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Year")
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(handleYearTextFieldChange), for: .editingChanged)
        return textField
    }()

    private lazy var monthTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Month")
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(handleMonthTextFieldChange), for: .editingChanged)
        return textField
    }()

    private lazy var dayTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Day")
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(handleDayTextFieldChange), for: .editingChanged)
        return textField
    }()

    private var allTextFields: [UITextField] {
        [yearTextField, monthTextField, dayTextField]
    }

    public override var isHidden: Bool {
        get {
            super.isHidden
        }
        set {
            self.resetUserInterface()
            super.isHidden = newValue
        }
    }

    private let viewModel: AddViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero)

        self.setupUserInterface()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(yearTextField)
        NSLayoutConstraint.activate([
            yearTextField.topAnchor.constraint(equalTo: topAnchor),
            yearTextField.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(monthTextField)
        NSLayoutConstraint.activate([
            monthTextField.topAnchor.constraint(equalTo: topAnchor),
            monthTextField.leadingAnchor.constraint(equalTo: yearTextField.trailingAnchor, constant: 12),
            monthTextField.widthAnchor.constraint(equalTo: yearTextField.widthAnchor, multiplier: 0.8)
        ])

        addSubview(dayTextField)
        NSLayoutConstraint.activate([
            dayTextField.topAnchor.constraint(equalTo: topAnchor),
            dayTextField.leadingAnchor.constraint(equalTo: monthTextField.trailingAnchor, constant: 12),
            dayTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayTextField.widthAnchor.constraint(equalTo: yearTextField.widthAnchor, multiplier: 0.8)
        ])
    }

    private func bind() {
        viewModel.$year
            .sink { [weak self] in self?.yearTextField.text = $0 }
            .store(in: &subscriptions)

        viewModel.$month
            .sink { [weak self] in self?.monthTextField.text = $0 }
            .store(in: &subscriptions)

        viewModel.$day
            .sink { [weak self] in self?.dayTextField.text = $0 }
            .store(in: &subscriptions)
    }

    private func resetUserInterface() {
        allTextFields.forEach { $0.resignFirstResponder() }
        viewModel.year = ""
        viewModel.month = ""
        viewModel.day = ""
    }

    @objc
    private func handleYearTextFieldChange(_ sender: UITextField) {
        viewModel.year = sender.text ?? ""
    }

    @objc
    private func handleMonthTextFieldChange(_ sender: UITextField) {
        viewModel.month = sender.text ?? ""
    }

    @objc
    private func handleDayTextFieldChange(_ sender: UITextField) {
        viewModel.day = sender.text ?? ""
    }
}
