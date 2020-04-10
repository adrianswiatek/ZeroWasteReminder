import UIKit

class ViewController: UIViewController {
    private lazy var temporaryLabel: UILabel = {
        let label = UILabel()
        label.text = "Zero Waste Reminder"
        label.textColor = .systemPurple
        label.font = .systemFont(ofSize: 32)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemFill
        view.addSubview(temporaryLabel)
        NSLayoutConstraint.activate([
            temporaryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temporaryLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
