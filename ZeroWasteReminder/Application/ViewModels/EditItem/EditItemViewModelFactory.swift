public final class EditItemViewModelFactory {
    private let itemsReadRepository: ItemsReadRepository
    private let itemsWriteRepository: ItemsWriteRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    public init(
        itemsReadRepository: ItemsReadRepository,
        itemsWriteRepository: ItemsWriteRepository,
        photosRepository: PhotosRepository,
        fileService: FileService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsReadRepository = itemsReadRepository
        self.itemsWriteRepository = itemsWriteRepository
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
    }

    public func create(for item: Item) -> EditItemViewModel {
        let viewModel = EditItemViewModel(
            itemsReadRepository: itemsReadRepository,
            itemsWriteRepository: itemsWriteRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )

        viewModel.set(item)
        return viewModel
    }
}
