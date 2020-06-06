import Combine
import UIKit

public final class EditViewController: UIViewController {
    private lazy var saveButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDoneButtonTap))

    private let scrollView: UIScrollView
    private let contentViewController: EditContentViewController
    private let loadingView: LoadingView

    private let viewModel: EditViewModel

    private var subscriptions: Set<AnyCancellable>
    private var deleteSubscription: AnyCancellable?

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel

        self.scrollView = AdaptiveScrollView()
        self.contentViewController = EditContentViewController(viewModel: viewModel)
        self.loadingView = LoadingView()

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
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = saveButton
    }

    private func bind() {
        viewModel.canSave
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)

        contentViewController.delete
            .sink { [weak self] in self?.handleDeleteButtonTap() }
            .store(in: &subscriptions)

        viewModel.needsShowPhoto
            .sink { [weak self] in
                let photoViewController = FullScreenPhotoViewController(image: $0)
                self?.present(photoViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.needsRemovePhoto
            .sink { [weak self] index in
                guard let self = self else { return }
                UIAlertController.presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
                    .sink { [weak self] _ in self?.viewModel.removePhoto(atIndex: index) }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)

        viewModel.needsCapturePhoto
            .compactMap { [weak self] in self?.tryCreateImagePickerController() }
            .sink { [weak self] in self?.present($0, animated: true) }
            .store(in: &subscriptions)
    }

    @objc
    private func handleTap() {
        view.endEditing(true)
    }

    @objc
    private func handleDoneButtonTap() {
        loadingView.show()

        viewModel.save()
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
                self?.loadingView.hide()
            }
            .store(in: &subscriptions)
    }

    private func handleDeleteButtonTap() {
        deleteSubscription = UIAlertController
            .presentConfirmationSheet(in: self, withConfirmationStyle: .destructive)
            .mapError { _ in ServiceError.general("") }
            .flatMap { [weak self] _ -> AnyPublisher<Void, ServiceError> in
                guard let self = self else {
                    return Empty<Void, ServiceError>().eraseToAnyPublisher()
                }
                self.loadingView.show()
                return self.viewModel.delete().eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] in
                    self?.loadingView.hide()
                    guard let self = self, case .failure(let error) = $0 else { return }
                    UIAlertController.presentError(in: self, withMessage: error.localizedDescription)
                },
                receiveValue: { [weak self] in self?.navigationController?.popViewController(animated: true) }
            )
    }

    private func tryCreateImagePickerController() -> UIViewController? {
        let cameraSourceType: UIImagePickerController.SourceType = .camera
        if UIImagePickerController.isSourceTypeAvailable(cameraSourceType) {
            return createImagePickerController(for: cameraSourceType)
        }

        let photoLibrarySourceType: UIImagePickerController.SourceType = .photoLibrary
        if UIImagePickerController.isSourceTypeAvailable(photoLibrarySourceType) {
            return createImagePickerController(for: photoLibrarySourceType)
        }

        return nil
    }

    private func createImagePickerController(
        for sourceType: UIImagePickerController.SourceType
    ) -> UIViewController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.mediaTypes = ["public.image"]
        imagePickerController.delegate = self
        return imagePickerController
    }
}

extension EditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = tryCompressImage(info[.originalImage] as? UIImage) else {
            assertionFailure("Cannot compress an image.")
            return
        }

        viewModel.addPhoto(image)
        picker.dismiss(animated: true)
    }

    private func tryCompressImage(_ image: UIImage?) -> UIImage? {
        guard let imageData = image?.jpegData(compressionQuality: 0.25) else {
            return nil
        }

        return UIImage(data: imageData)
    }
}
