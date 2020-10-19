public final class AddItemViewModelFactory {
    private let itemsWriteRepository: ItemsWriteRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    public init(
        itemsWriteRepository: ItemsWriteRepository,
        photosRepository: PhotosRepository,
        fileService: FileService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsWriteRepository = itemsWriteRepository
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
    }

    public func create(for list: List) -> AddItemViewModel {
        .init(
            list: list,
            itemsWriteRepository: itemsWriteRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }
}
