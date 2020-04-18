import Combine
import UIKit

public final class ExpirationDateView: UIView {
    public override var isHidden: Bool {
        get {
            super.isHidden
        }
        set {
            self.viewModel.hideDatePicker()
            super.isHidden = newValue
        }
    }

    private lazy var dateButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 4)
        button.titleEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 0)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .light)
        button.backgroundColor = .init(white: 0.94, alpha: 1)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDateButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(handleDatePickerValueChange), for: .valueChanged)
        return datePicker
    }()

    private let viewModel: ExpirationDateViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ExpirationDateViewModel) {
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

        addSubview(dateButton)
        NSLayoutConstraint.activate([
            dateButton.topAnchor.constraint(equalTo: topAnchor),
            dateButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            dateButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: dateButton.bottomAnchor),
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func bind() {
        viewModel.$date
            .assign(to: \.date, on: datePicker)
            .store(in: &subscriptions)

        viewModel.formattedDate
            .sink { [weak self] in self?.dateButton.setTitle($0, for: .normal) }
            .store(in: &subscriptions)

        viewModel.isDatePickerVisible
            .sink { [weak self] in self?.showDatePicker($0) }
            .store(in: &subscriptions)
    }

    private func showDatePicker(_ show: Bool) {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: [.transitionCrossDissolve, .curveEaseInOut],
            animations: { self.datePicker.isHidden = !show }
        )
    }

    @objc
    private func handleDateButtonTap(_ sender: UIButton) {
        viewModel.toggleDatePicker()
    }

    @objc
    private func handleDatePickerValueChange(_ sender: UIDatePicker) {
        viewModel.date = sender.date
    }
}
