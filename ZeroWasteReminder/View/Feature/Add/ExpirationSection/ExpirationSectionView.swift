import UIKit

public final class ExpirationSectionView: UIView {
    private let expirationLabel: UILabel = .defaultWithText(.localized(.expiration))

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

    private var bottomConstraints: [Int: NSLayoutConstraint]

    private let viewModel: AddViewModel

    public init(viewModel: AddViewModel) {
        self.viewModel = viewModel
        self.expirationDateView = .init(viewModel: viewModel.expirationDateViewModel)
        self.expirationPeriodView = .init(viewModel: viewModel.expirationPeriodViewModel)
        self.bottomConstraints = [:]

        super.init(frame: .zero)

        self.setupView()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        setControlsVisibility()

        addSubview(expirationLabel)
        NSLayoutConstraint.activate([
            expirationLabel.topAnchor.constraint(equalTo: topAnchor),
            expirationLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
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
            expirationDateView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        addSubview(expirationPeriodView)
        NSLayoutConstraint.activate([
            expirationPeriodView.topAnchor.constraint(equalTo: expirationSegmentedControl.bottomAnchor, constant: 8),
            expirationPeriodView.leadingAnchor.constraint(equalTo: leadingAnchor),
            expirationPeriodView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        bottomConstraints = [
            0: expirationSegmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            1: expirationDateView.bottomAnchor.constraint(equalTo: bottomAnchor),
            2: expirationPeriodView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]

        bottomConstraints[0]?.isActive = true
    }

    @objc
    private func handleSegmentedControlChange(_ sender: UISegmentedControl) {
        setExpirationTypeIndex(sender.selectedSegmentIndex)
        setBottomConstraint(sender.selectedSegmentIndex)
        setControlsVisibility()
    }

    private func setExpirationTypeIndex(_ selectedIndex: Int) {
        viewModel.expirationTypeIndex = selectedIndex
    }

    private func setBottomConstraint(_ selectedIndex: Int) {
        bottomConstraints.forEach { $0.value.isActive = false }
        bottomConstraints[selectedIndex]?.isActive = true
    }

    private func setControlsVisibility() {
        func setVisibility() {
            expirationDateView.isHidden = !viewModel.isExpirationDateVisible
            expirationPeriodView.isHidden = !viewModel.isExpirationPeriodVisible
        }

        guard let superview = superview else {
            setVisibility()
            return
        }

        UIView.transition(with: superview, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            setVisibility()
        })
    }
}
