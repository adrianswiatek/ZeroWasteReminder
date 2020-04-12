import UIKit

public final class AddViewController: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUserInterface()
    }

    private func setupUserInterface() {
        title = "Add item"
        view.backgroundColor = .white
    }
}
