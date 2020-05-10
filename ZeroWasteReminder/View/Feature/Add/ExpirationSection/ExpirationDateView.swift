import Combine
import UIKit

public final class ExpirationDateView: UIView {
    public override var isHidden: Bool {
        didSet {
            viewModel.hideDatePicker()
        }
    }

    private let dateButton = ExpirationDateButton(type: .system)
    private let datePicker = ExpirationDatePicker()

    private let viewModel: ExpirationDateViewModel
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: ExpirationDateViewModel) {
        self.viewModel = viewModel
        self.subscriptions = []

        super.init(frame: .zero)

        self.setupView()
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    private func setupView() {
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
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func bind() {
        dateButton.tap
            .sink { [weak self] in self?.viewModel.toggleDatePicker() }
            .store(in: &subscriptions)

        datePicker.value
            .assign(to: \.date, on: viewModel)
            .store(in: &subscriptions)

        viewModel.$date
            .assign(to: \.date, on: datePicker)
            .store(in: &subscriptions)

        viewModel.formattedDate
            .sink { [weak self] in self?.dateButton.setTitle($0, for: .normal) }
            .store(in: &subscriptions)

        viewModel.isDatePickerVisible
            .sink { [weak self] in self?.datePicker.setVisibility($0) }
            .store(in: &subscriptions)
    }
}
