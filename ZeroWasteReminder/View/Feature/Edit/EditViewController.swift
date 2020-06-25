import Combine
import UIKit

public final class EditViewController: UIViewController {
    private lazy var saveButton: UIBarButtonItem =
        .doneButton(target: self, action: #selector(handleDoneButtonTap))

    private let scrollView: AdaptiveScrollView
    private let contentViewController: EditContentViewController
    private let loadingView: LoadingView
    private let warningBarView: WarningBarView

    private let viewModel: EditViewModel

    private var subscriptions: Set<AnyCancellable>
    private var deleteSubscription: AnyCancellable?

    public init(viewModel: EditViewModel) {
        self.viewModel = viewModel

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
        navigationItem.rightBarButtonItem = saveButton
    }

    private func bind() {
        viewModel.canSave
            .assign(to: \.isEnabled, on: saveButton)
            .store(in: &subscriptions)

        contentViewController.delete
            .sink { [weak self] in self?.handleDeleteButtonTap() }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsShowImage
            .sink { [weak self] in
                let photoViewController = FullScreenPhotoViewController(image: $0)
                self?.present(photoViewController, animated: true)
            }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsRemoveImage
            .sink { [weak self] in self?.viewModel.photosViewModel.deleteImage(at: $0) }
            .store(in: &subscriptions)

        viewModel.photosViewModel.needsCaptureImage
            .compactMap { [weak self] in
                switch $0 {
                case .camera:
                    return self?.tryCreateImagePickerController(for: .camera)
                case .photoLibrary:
                    return self?.tryCreateImagePickerController(for: .photoLibrary)
                }
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

    @objc
    private func handleTap() {
        view.endEditing(true)
    }

    @objc
    private func handleDoneButtonTap() {
        loadingView.show()

        viewModel.save()
            .sink(
                receiveCompletion: { [weak self] in
                    defer { self?.loadingView.hide() }
                    guard let self = self, case .failure(let error) = $0 else { return }
                    UIAlertController.presentError(in: self, withMessage: error.localizedDescription)
                },
                receiveValue: { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
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

    private func tryCreateImagePickerController(
        for sourceType: UIImagePickerController.SourceType
    ) -> UIViewController? {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            return createImagePickerController(for: sourceType)
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
        if let imageUrl = info[.imageURL] as? URL {
            viewModel.photosViewModel.addImage(at: imageUrl)
        } else if let photo = info[.originalImage] as? UIImage {
            viewModel.photosViewModel.addImage(photo)
        }

        picker.dismiss(animated: true)
    }
}
