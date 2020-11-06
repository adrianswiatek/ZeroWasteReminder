import Combine
import UIKit

public final class AddItemViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton { [weak self] in self?.dismiss(animated: true) }

    private lazy var doneButton: UIBarButtonItem =
        .doneButton { [weak self] in self?.viewModel.saveItem() }

    private let scrollView: AdaptiveScrollView
    private let contentViewController: AddItemContentViewController
    private let loadingView: LoadingView
    private let warningBarView: WarningBarView

    private let viewModel: AddItemViewModel
    private let coordinator: AddItemCoordinator
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddItemViewModel, coordinator: AddItemCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.subscriptions = []

        self.contentViewController = .init(viewModel: viewModel)
        self.scrollView = .init()
        self.loadingView = .init()
        self.warningBarView = .init()

        super.init(nibName: nil, bundle: nil)

        self.addChild(self.contentViewController)
        self.contentViewController.didMove(toParent: self)
        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported.")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGestureRecognizer()
        self.setupNavigationItem()
        self.setupView()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.cleanUp()
    }

    private func setupNavigationItem() {
        navigationItem.title = .localized(.addItem)

        navigationItem.leftBarButtonItem = dismissButton
        navigationItem.rightBarButtonItem = doneButton
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        let contentView: UIView = contentViewController.view

        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -64)
        ])

        scrollView.addSubview(warningBarView)
        NSLayoutConstraint.activate([
            warningBarView.leadingAnchor.constraint(
                equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: 16
            ),
            warningBarView.bottomAnchor.constraint(equalTo:
                scrollView.layoutMarginsGuide.bottomAnchor
            ),
            warningBarView.trailingAnchor.constraint(equalTo:
                scrollView.layoutMarginsGuide.trailingAnchor, constant: -16
            )
        ])

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        let navigationView: UIView! = navigationController?.view
        assert(navigationView != nil)

        navigationView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: navigationView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: navigationView.bottomAnchor),
            loadingView.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor)
        ])
    }

    private func bind() {
        viewModel.canSaveItem.combineLatest(viewModel.canRemotelyConnect)
            .map { $0 && $1 }
            .assign(to: \.isEnabled, on: doneButton)
            .store(in: &subscriptions)

        viewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.photosViewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.canRemotelyConnect
            .sink { [weak self] in
                self?.warningBarView.setVisibility(!$0)
                self?.scrollView.additionalOffset = self?.warningBarView.height ?? 0
            }
            .store(in: &subscriptions)
    }

    private func setupGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleViewTap))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }

    private func handleRequest(_ request: AddItemViewModel.Request) {
        switch request {
        case .dismiss:
            dismiss(animated: true)
        case .setAlert:
            coordinator.navigateToAlert(withOption: viewModel.alertOption, in: self)
        case .showErrorMessage(let message):
            UIAlertController.presentError(in: self, withMessage: message)
        }
    }

    private func handleRequest(_ request: PhotosViewModel.Request) {
        switch request {
        case .capturePhoto(let target):
            coordinator.navigateToImagePicker(for: target, with: self, in: self) { [weak self] in
                self?.viewModel.photosViewModel.requestSubject.send(.hidePhotosActivityIndicator)
            }
        case .removePhoto(let photo):
            UIAlertController.presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
                .sink { [weak self] _ in self?.viewModel.photosViewModel.removePhoto(photo) }
                .store(in: &self.subscriptions)
        case .showPhoto(let photo):
            coordinator.navigateToFullScreenPhoto(for: photo, in: self)
        default:
            break
        }
    }

    @objc
    private func handleViewTap() {
        view.endEditing(true)
    }
}

extension AddItemViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let imageUrl = info[.imageURL] as? URL {
            viewModel.photosViewModel.addImage(at: imageUrl)
        } else if let photo = info[.originalImage] as? UIImage {
            viewModel.photosViewModel.addImage(photo)
        }

        picker.dismiss(animated: true)
    }
}
