import UIKit

public final class ExpirationDateView: UIView {
    private let expirationDateSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["None", "Date", "Period"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .accent
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ], for: .selected)
        segmentedControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .light)
        ], for: .normal)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let yearTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Year")
        textField.keyboardType = .numberPad
        return textField
    }()

    private let monthTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Month")
        textField.keyboardType = .numberPad
        return textField
    }()

    private let dayTextField: UITextField = {
        let textField = AddItemTextField(placeholder: "Day")
        textField.keyboardType = .numberPad
        return textField
    }()

    public init() {
        super.init(frame: .zero)
        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false

        expirationDateSegmentedControl.addTarget(
            self,
            action: #selector(handleSegmentedControlChange),
            for: .valueChanged
        )

        setControls(visible: false)

        addSubview(expirationDateSegmentedControl)
        NSLayoutConstraint.activate([
            expirationDateSegmentedControl.topAnchor.constraint(equalTo: topAnchor),
            expirationDateSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            expirationDateSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(yearTextField)
        NSLayoutConstraint.activate([
            yearTextField.topAnchor.constraint(equalTo: expirationDateSegmentedControl.bottomAnchor, constant: 16),
            yearTextField.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])

        addSubview(monthTextField)
        NSLayoutConstraint.activate([
            monthTextField.topAnchor.constraint(equalTo: expirationDateSegmentedControl.bottomAnchor, constant: 16),
            monthTextField.leadingAnchor.constraint(equalTo: yearTextField.trailingAnchor, constant: 16),
            monthTextField.widthAnchor.constraint(equalTo: yearTextField.widthAnchor, multiplier: 0.8)
        ])

        addSubview(dayTextField)
        NSLayoutConstraint.activate([
            dayTextField.topAnchor.constraint(equalTo: expirationDateSegmentedControl.bottomAnchor, constant: 16),
            dayTextField.leadingAnchor.constraint(equalTo: monthTextField.trailingAnchor, constant: 16),
            dayTextField.trailingAnchor.constraint(equalTo: trailingAnchor),
            dayTextField.widthAnchor.constraint(equalTo: yearTextField.widthAnchor, multiplier: 0.8)
        ])
    }

    @objc
    private func handleSegmentedControlChange(_ sender: UISegmentedControl) {
        setControls(visible: sender.selectedSegmentIndex == 1)
    }

    private func setControls(visible: Bool) {
        UIView.transition(with: self, duration: 0.3, options: [.transitionCrossDissolve], animations: { [weak self] in
            [self?.yearTextField, self?.monthTextField, self?.dayTextField].forEach { $0?.isHidden = !visible }
        })
    }
}
