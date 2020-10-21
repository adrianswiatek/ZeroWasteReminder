import Combine
import UIKit

public final class AddItemViewModel {
    @Published public var name: String
    @Published public var notes: String
    @Published public var expirationTypeIndex: Int
    @Published public private(set) var alertOption: AlertOption

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public let requestSubject: PassthroughSubject<Request, Never>

    public var expirationType: AnyPublisher<ExpirationType, Never> {
        expirationTypeSubject.eraseToAnyPublisher()
    }

    public var canSaveItem: AnyPublisher<Bool, Never> {
        expirationType.combineLatest(
            $name.map { !$0.isEmpty },
            expirationPeriodViewModel.isValid
        ) { expirationType, isNameValid, isPeriodValid in
            switch expirationType {
            case .none where isNameValid: return true
            case .date where isNameValid: return true
            case .period where isPeriodValid && isNameValid: return true
            default: return false
            }
        }.eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: Bool {
        expirationTypeIndex == ExpirationType.date.index
    }

    public var isExpirationPeriodVisible: Bool {
        expirationTypeIndex == ExpirationType.period.index
    }

    public var isAlertSectionVisible: AnyPublisher<Bool, Never> {
        $expirationTypeIndex
            .map { ExpirationType.fromIndex($0) }
            .map { $0 == .date || $0 == .period }
            .eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosViewModel
    public let expirationDateViewModel: ExpirationDateViewModel
    public let expirationPeriodViewModel: ExpirationPeriodViewModel

    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private let expirationTypeSubject: CurrentValueSubject<ExpirationType, Never>

    private let list: List

    private let itemsWriteRepository: ItemsWriteRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher

    private var subscriptions: Set<AnyCancellable>

    public init(
        list: List,
        itemsWriteRepository: ItemsWriteRepository,
        photosRepository: PhotosRepository,
        fileService: FileService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsWriteRepository = itemsWriteRepository
        self.list = list
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher

        self.name = ""
        self.notes = ""
        self.alertOption = .none

        self.expirationTypeIndex = ExpirationType.none.index

        self.photosViewModel = .init(photosRepository: photosRepository, fileService: fileService)
        self.expirationDateViewModel = .init(initialDate: .init())
        self.expirationPeriodViewModel = .init(initialPeriodType: .day)

        self.requestSubject = .init()
        self.isLoadingSubject = .init()
        self.expirationTypeSubject = .init(ExpirationType.none)

        self.subscriptions = []

        self.bind()
    }

    public func saveItem() {
        guard let item = tryCreateItem() else {
            preconditionFailure("Unable to create item.")
        }

        isLoadingSubject.send(true)
        itemsWriteRepository.add(ItemToSave(item, list))
    }

    public func setLoading(_ isLoading: Bool) {
        isLoadingSubject.send(isLoading)
    }

    public func cleanUp() {
        _ = fileService.removeTemporaryItems()
    }

    private func bind() {
        $expirationTypeIndex
            .map { ExpirationType.fromIndex($0) }
            .sink { [weak self] in self?.expirationTypeSubject.send($0) }
            .store(in: &subscriptions)

        eventDispatcher.events
            .sink { [weak self] in self?.handleEvent($0) }
            .store(in: &subscriptions)

        photosViewModel.requestSubject
            .sink { [weak self] in self?.handlePhotoRequests($0) }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ event: AppEvent) {
        switch event {
        case let event as ItemAdded:
            photosRepository.update(photosViewModel.photosChangeset, for: event.item)
        case is PhotosUpdated:
            requestSubject.send(.dismiss)
        case let event as AlertSet:
            alertOption = event.option
        case let event as ErrorOccured:
            isLoadingSubject.send(false)
            requestSubject.send(.showErrorMessage(event.error.localizedDescription))
        case is NoResultOccured:
            requestSubject.send(.dismiss)
        default:
            return
        }
    }

    private func handlePhotoRequests(_ request: PhotosViewModel.Request) {
        switch request {
        case .capturePhoto:
            isLoadingSubject.send(true)
        default:
            return
        }
    }

    private func tryCreateItem() -> Item? {
        guard !name.isEmpty, let expiration = expiration() else {
            return nil
        }

        return Item(id: itemsWriteRepository.nextId(), name: name, listId: list.id)
            .withNotes(notes)
            .withExpiration(expiration)
            .withAlertOption(alertOption)
    }

    private func expiration() -> Expiration? {
        switch expirationTypeSubject.value {
        case .none: return Expiration.none
        case .date: return expirationDateViewModel.expiration
        case .period: return expirationPeriodViewModel.expiration
        }
    }
}

public extension AddItemViewModel {
    enum Request: Equatable {
        case dismiss
        case setAlert
        case showErrorMessage(_ message: String)
    }
}
