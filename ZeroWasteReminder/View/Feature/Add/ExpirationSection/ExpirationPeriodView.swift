import Combine
import UIKit

public final class ExpirationPeriodView: UIView {
    public override var isHidden: Bool {
        get {
            super.isHidden
        }
        set {
            self.resetUserInterface()
            super.isHidden = newValue
        }
    }

    private lazy var periodTextField: UITextField = {
        let textField = DefaultTextField(placeholder: "Period")
        textField.keyboardType = .numberPad
        textField.addTarget(self, action: #selector(handlePeriodTextFieldChange), for: .editingChanged)
        textField.delegate = self
        return textField
    }()

    private lazy var periodTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var periodStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 0
        stepper.maximumValue = Double(PeriodType.allCases.count - 1)
        stepper.value = Double(viewModel.periodTypeIndex)
        stepper.addTarget(self, action: #selector(handlePeriodStepperChange), for: .valueChanged)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        return stepper
    }()

    private let viewModel: ExpirationPeriodViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ExpirationPeriodViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []
        super.init(frame: .zero)
        self.setupUserInterface()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(periodTextField)
        NSLayoutConstraint.activate([
            periodTextField.topAnchor.constraint(equalTo: topAnchor),
            periodTextField.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(periodTypeLabel)
        NSLayoutConstraint.activate([
            periodTypeLabel.leadingAnchor.constraint(equalTo: periodTextField.trailingAnchor, constant: 32),
            periodTypeLabel.centerYAnchor.constraint(equalTo: periodTextField.centerYAnchor)
        ])

        addSubview(periodStepper)
        NSLayoutConstraint.activate([
            periodStepper.leadingAnchor.constraint(equalTo: periodTypeLabel.trailingAnchor, constant: 16),
            periodStepper.trailingAnchor.constraint(equalTo: trailingAnchor),
            periodStepper.centerYAnchor.constraint(equalTo: periodTypeLabel.centerYAnchor)
        ])
    }

    private func bind() {
        viewModel.periodType
            .map { $0.namePlural }
            .sink { [weak self] in self?.periodTypeLabel.text = $0 }
            .store(in: &subscriptions)

        viewModel.$periodTypeIndex
            .sink { [weak self] in self?.periodStepper.value = Double($0) }
            .store(in: &subscriptions)

        viewModel.$period
            .sink { [weak self] in self?.periodTextField.text = $0 }
            .store(in: &subscriptions)
    }

    @objc
    private func handlePeriodTextFieldChange(_ sender: UITextField) {
        viewModel.period = sender.text ?? ""
    }

    @objc
    private func handlePeriodStepperChange(_ sender: UIStepper) {
        viewModel.periodTypeIndex = Int(sender.value)
    }

    private func resetUserInterface() {
        periodTextField.resignFirstResponder()
        viewModel.period = ""
        viewModel.periodTypeIndex = 0
    }
}

extension ExpirationPeriodView: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard var text = textField.text, let range = Range(range, in: text) else {
            return false
        }

        text.replaceSubrange(range, with: string)
        return viewModel.canUpdate(period: text)
    }
}
