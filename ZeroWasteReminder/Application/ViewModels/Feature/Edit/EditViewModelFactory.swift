public final class EditViewModelFactory {
    private let itemsRepository: ItemsRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    public init(
        itemsRepository: ItemsRepository,
        photosRepository: PhotosRepository,
        fileService: FileService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsRepository = itemsRepository
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
    }

    public func create(for item: Item) -> EditViewModel {
        .init(
            item: item,
            itemsRepository: itemsRepository,
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier,
            eventDispatcher: eventDispatcher
        )
    }
}
