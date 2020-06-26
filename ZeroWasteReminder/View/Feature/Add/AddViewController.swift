import Combine
import UIKit

public final class AddViewController: UIViewController {
    private lazy var dismissButton: UIBarButtonItem =
        .dismissButton(target: self, action: #selector(handleDismiss))

    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleConfirm))

    private let scrollView: AdaptiveScrollView
    private let contentViewController: AddContentViewController
    private let loadingView: LoadingView
    private let warningBarView: WarningBarView

    private let viewModel: AddViewModel
    private let viewControllerFactory: ViewControllerFactory
    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: AddViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory
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
        navigationItem.title = "Add item"

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
                equalTo: scrollView.layoutMarginsGuide.leadingAnchor, constant: -8
            ),
            warningBarView.bottomAnchor.constraint(equalTo:
                scrollView.layoutMarginsGuide.bottomAnchor, constant: 8
            ),
            warningBarView.trailingAnchor.constraint(equalTo:
                scrollView.layoutMarginsGuide.trailingAnchor, constant: 8
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
            .sink { [weak self] in self?.doneButton.isEnabled = $0 && $1 }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsShowImage
            .sink { [weak self] in
                let photoViewController = FullScreenPhotoViewController(image: $0)
                self?.present(photoViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsRemoveImage
            .sink { [weak self] index in
                guard let self = self else { return }
                UIAlertController.presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
                    .sink { [weak self] _ in self?.viewModel.photosViewModel.deleteImage(at: index) }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsCaptureImage
            .compactMap { [weak self] target in
                guard let self = self else { return nil }
                return self.viewControllerFactory.imagePickerController(
                    for: target,
                    with: self
                )
            }
            .sink { [weak self] in self?.present($0, animated: true) }
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

    @objc
    private func handleViewTap() {
        view.endEditing(true)
    }

    @objc
    private func handleDismiss() {
        dismiss(animated: true)
    }

    @objc
    private func handleConfirm() {
        loadingView.show()

        viewModel.saveItem()
            .sink(
                receiveCompletion: { [weak self] in
                    guard case .failure(let error) = $0, let self = self else { return }
                    self.loadingView.hide()
                    UIAlertController.presentError(in: self, withMessage: error.localizedDescription)
                },
                receiveValue: { [weak self] _ in
                    self?.dismiss(animated: true)
                    self?.loadingView.hide()
                }
            )
            .store(in: &subscriptions)
    }
}

extension AddViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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
