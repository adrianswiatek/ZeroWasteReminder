import Combine
import UIKit

public final class EditViewController: UIViewController {
    private lazy var doneButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDoneButtonTap))

    private let scrollView: AdaptiveScrollView
    private let contentViewController: EditContentViewController
    private let loadingView: LoadingView
    private let warningBarView: WarningBarView

    private let viewModel: EditViewModel
    private let viewControllerFactory: ViewControllerFactory

    private var subscriptions: Set<AnyCancellable>

    public init(viewModel: EditViewModel, factory: ViewControllerFactory) {
        self.viewModel = viewModel
        self.viewControllerFactory = factory

        self.scrollView = .init()
        self.contentViewController = .init(viewModel: viewModel)
        self.loadingView = .init()
        self.warningBarView = .init()

        self.subscriptions = []

        super.init(nibName: nil, bundle: nil)

        self.bind()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("Not supported")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationItem()
        self.setupView()
        self.setupTapGestureRecognizer()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel.cleanUp()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        let contentView: UIView = contentViewController.view
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -24),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48)
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

    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = doneButton
    }

    private func bind() {
        viewModel.requestSubject
            .sink { [weak self] in self?.handleRequest($0) }
            .store(in: &subscriptions)

        viewModel.photosViewModel.requestSubject
            .sink { [weak self] in self?.handlePhotoRequest($0) }
            .store(in: &subscriptions)

        viewModel.canSave
            .assign(to: \.isEnabled, on: doneButton)
            .store(in: &subscriptions)

        viewModel.isLoading
            .sink { [weak self] in $0 ? self?.loadingView.show() : self?.loadingView.hide() }
            .store(in: &subscriptions)

        viewModel.canRemotelyConnect
            .sink { [weak self] in
                self?.warningBarView.setVisibility(!$0)
                self?.scrollView.additionalOffset = self?.warningBarView.height ?? 0
            }
            .store(in: &subscriptions)
    }

    private func handleRequest(_ request: EditViewModel.Request) {
        switch request {
        case .dismiss:
            navigationController?.popViewController(animated: true)
        case .moveCurrentItem:
            present(viewControllerFactory.moveItemViewController(item: viewModel.originalItem), animated: true)
        case .removeCurrentItem:
            handleRemoveButtonTap()
        }
    }

    private func handlePhotoRequest(_ request: PhotosViewModel.Request) {
        switch request {
        case .capturePhoto(let target):
            viewControllerFactory.imagePickerController(for: target, with: self).map {
                present($0, animated: true)
            }
        case .removePhoto(let photo):
            viewModel.photosViewModel.deletePhoto(photo)
        case .showPhoto(let photo):
            present(FullScreenPhotoViewController(image: photo.asImage), animated: true)
        case .showPhotoAt:
            break
        }
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }

    @objc
    private func handleDoneButtonTap() {
        viewModel.saveItem()
    }

    private func handleRemoveButtonTap() {
        UIAlertController
            .presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
            .sink { [weak self] _ in self?.viewModel.remove() }
            .store(in: &subscriptions)
    }
}

extension EditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
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
