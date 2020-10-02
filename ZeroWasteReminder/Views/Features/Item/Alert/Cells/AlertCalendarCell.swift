import UIKit

public final class AlertCalendarCell: UITableViewCell {
    private var viewModel: AlertDateCellViewModel?

    private let datePicker: UIDatePicker = configure(.init()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.datePickerMode = .date
        $0.preferredDatePickerStyle = .inline
        $0.tintColor = .expired
    }

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.setupView()
        self.setDatePickerActions()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public func set(_ viewModel: AlertDateCellViewModel) {
        self.viewModel = viewModel

        if viewModel.date == nil {
            viewModel.date = datePicker.date
        } else {
            viewModel.date.map { datePicker.date = $0 }
        }
    }

    private func setupView() {
        tintColor = .label
        backgroundColor = .secondarySystemBackground

        contentView.addAndFill(datePicker)
    }

    private func setDatePickerActions() {
        let dateUpdatedAction = UIAction { [weak self] in
            let date = ($0.sender as? UIDatePicker)?.date
            date.map { self?.viewModel?.date = $0 }
        }
        datePicker.addAction(dateUpdatedAction, for: .valueChanged)
    }
}
