import UIKit

public final class RemainingView: UIView {
    public var viewModel: RemainingViewModel! {
        didSet {
            reloadUserInterface()
        }
    }

    private let remainingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 13, weight: .light)
        return label
    }()

    private let lineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = .init(width: 0, height: 2)
        return view
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

        addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            lineView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 4)
        ])

        addSubview(remainingLabel)
        NSLayoutConstraint.activate([
            remainingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            remainingLabel.trailingAnchor.constraint(equalTo: lineView.leadingAnchor, constant: -8),
            remainingLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func reloadUserInterface() {
        remainingLabel.text = viewModel.formattedValue

        let color = colorForRemainingView(basedOn: viewModel.state)
        lineView.backgroundColor = color
        lineView.layer.shadowColor = color.cgColor
    }

    private func colorForRemainingView(basedOn state: RemainingState) -> UIColor {
        switch state {
        case .valid(_, _): return .good
        case .almostExpired: return .lastDay
        case .expired: return .stale
        case .notDefined: return .systemGray3
        }
    }
}
