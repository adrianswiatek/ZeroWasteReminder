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

    private lazy var periodTextField = configure(ExpirationPeriodTextField(placeholder: .localized(.period))) {
        $0.keyboardType = .numberPad
        $0.delegate = self
        $0.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
        $0.addAction(UIAction { [weak self] in
            guard let textField = $0.sender as? UITextField else { return }
            self?.viewModel.period = textField.text ?? ""
        }, for: .editingChanged)
    }

    private lazy var periodTypeLabel: UILabel = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .secondaryLabel
        $0.font = .systemFont(ofSize: 16)
    }

    private lazy var periodStepper: UIStepper = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.minimumValue = 0
        $0.maximumValue = Double(PeriodType.allCases.count - 1)
        $0.value = Double(viewModel.periodTypeIndex)
        $0.addAction(UIAction { [weak self] in
            guard let stepper = $0.sender as? UIStepper else { return }
            self?.viewModel.periodTypeIndex = Int(stepper.value)
        }, for: .valueChanged)
    }

    private let viewModel: ExpirationPeriodViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ExpirationPeriodViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []
        super.init(frame: .zero)
        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(periodTextField)
        NSLayoutConstraint.activate([
            periodTextField.topAnchor.constraint(equalTo: topAnchor),
            periodTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            periodTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
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
