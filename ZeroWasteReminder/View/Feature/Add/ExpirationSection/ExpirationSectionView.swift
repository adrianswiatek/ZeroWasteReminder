import UIKit

public final class ExpirationSectionView: UIView {
    private let expirationLabel: UILabel = {
        let label = UILabel()
        label.text = "Expiration"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var expirationSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ExpirationType.allCases.map { $0.nameTitleCased })
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .accent
        segmentedControl.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 13, weight: .bold)
        ], for: .selected)
        segmentedControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 13, weight: .light)
        ], for: .normal)
        segmentedControl.addTarget(self, action: #selector(handleSegmentedControlChange), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let expirationDateView: ExpirationDateView
    private let expirationPeriodView: ExpirationPeriodView

    private let viewModel: AddViewModel

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.expirationDateView = .init(viewModel: viewModel.expirationDateViewModel)
        self.expirationPeriodView = .init(viewModel: viewModel.expirationPeriodViewModel)

        super.init(frame: .zero)

        self.setupUserInterface()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupUserInterface() {
        translatesAutoresizingMaskIntoConstraints = false

        setControlsVisibility()

        addSubview(expirationLabel)
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: topAnchor),
            expirationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
        ])

        addSubview(expirationSegmentedControl)
        NSLayoutConstraint.activate([
            expirationSegmentedControl.topAnchor.constraint(equalTo: expirationLabel.bottomAnchor, constant: 8),
            expirationSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            expirationSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(expirationDateView)
        NSLayoutConstraint.activate([
            expirationDateView.topAnchor.constraint(equalTo: expirationSegmentedControl.bottomAnchor, constant: 16),
            expirationDateView.leadingAnchor.constraint(equalTo: leadingAnchor),
            expirationDateView.bottomAnchor.constraint(equalTo: bottomAnchor),
            expirationDateView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(expirationPeriodView)
        NSLayoutConstraint.activate([
            expirationPeriodView.topAnchor.constraint(equalTo: expirationSegmentedControl.bottomAnchor, constant: 8),
            expirationPeriodView.leadingAnchor.constraint(equalTo: leadingAnchor),
            expirationPeriodView.bottomAnchor.constraint(equalTo: bottomAnchor),
            expirationPeriodView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    @objc
    private func handleSegmentedControlChange(_ sender: UISegmentedControl) {
        viewModel.expirationTypeIndex = sender.selectedSegmentIndex
        setControlsVisibility()
    }

    private func setControlsVisibility() {
        UIView.transition(
            with: self,
            duration: 0.3,
            options: [.transitionCrossDissolve],
            animations: { [weak self] in
                guard let self = self else { return }
                self.expirationDateView.isHidden = !self.viewModel.isExpirationDateVisible
                self.expirationPeriodView.isHidden = !self.viewModel.isExpirationPeriodVisible
            }
        )
    }
}
