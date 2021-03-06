import Combine
import UIKit
import UserNotifications

public final class EditItemViewModel {
    @Published public var name: String
    @Published public var notes: String
    @Published public var item: Item
    @Published public private(set) var alertOption: AlertOption

    public let requestSubject: PassthroughSubject<Request, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public var expirationDate: AnyPublisher<(date: Date, formatted: String), Never> {
        expirationDateSubject
            .map { [weak self] in ($0 ?? Date(), self?.formattedDate($0) ?? .localized(.toggleDatePicker)) }
            .eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: AnyPublisher<Bool, Never> {
        isExpirationDateVisibleSubject.eraseToAnyPublisher()
    }

    public var isAlertSectionVisible: AnyPublisher<Bool, Never> {
        expirationDateSubject.map { $0?.isInTheFuture() ?? false }.eraseToAnyPublisher()
    }

    public var isRemoveDateButtonEnabled: AnyPublisher<Bool, Never> {
        expirationDateSubject.map { $0 != nil }.eraseToAnyPublisher()
    }

    public var canUseNotifications: AnyPublisher<Bool, Never> {
        statusNotifier.notificationStatus.map { $0 == .authorized }.eraseToAnyPublisher()
    }

    public var state: AnyPublisher<RemainingState, Never> {
        expirationDateSubject
            .map { $0 != nil ? Expiration.date($0!) : .none }
            .map { RemainingState(expiration: $0) }
            .eraseToAnyPublisher()
    }

    public var canSave: AnyPublisher<Bool, Never> {
        let canSavePublisher = Publishers.CombineLatest(itemHasChanged, photoIdsHaveChanged).map { $0 || $1 }
        return Just(false).merge(with: canSavePublisher).eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosViewModel

    private var itemHasChanged: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest4($name, $notes, expirationDateSubject, $alertOption)
            .map { [weak self] in (self?.item, $0, $1, $2, $3) }
            .map { $1.isEmpty || ItemSnapshot(name: $1, notes: $2, expirationDate: $3, alertOption: $4).equals($0) }
            .map { !$0 }
            .eraseToAnyPublisher()
    }

    private var photoIdsHaveChanged: AnyPublisher<Bool, Never> {
        thumbnails
            .delay(for: .milliseconds(100), scheduler: DispatchQueue.global())
            .map { $0.map(\.id) }
            .map { [weak self] in $0 != self?.originalPhotoIds }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private var thumbnails: AnyPublisher<[Photo], Never> {
        photosViewModel.thumbnails.eraseToAnyPublisher()
    }

    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>
    private let hasUserAgreedForNotificationsSubject: CurrentValueSubject<Bool, Never>

    private var originalPhotoIds: [Id<Photo>]
    private let itemsReadRepository: ItemsReadRepository
    private let itemsWriteRepository: ItemsWriteRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

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
        self.originalPhotoIds = []
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
        self.dateFormatter = .fullDate

        self.name = ""
        self.notes = ""
        self.item = .empty
        self.expirationDateSubject = .init(nil)
        self.alertOption = .none

        self.requestSubject = .init()
        self.isLoadingSubject = .init()
        self.isExpirationDateVisibleSubject = .init(false)
        self.hasUserAgreedForNotificationsSubject = .init(true)

        self.photosViewModel = .init(
            photosRepository: photosRepository,
            fileService: fileService,
            statusNotifier: statusNotifier
        )

        self.subscriptions = []

        self.bind()
    }

    public func set(_ item: Item) {
        self.item = item
        self.alertOption = item.alertOption
        self.photosViewModel.fetchThumbnails(for: item)
    }

    public func cleanUp() {
        _ = fileService.removeTemporaryItems()
        isLoadingSubject.send(false)
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    public func saveItem() {
        guard let item = tryCreateItem(name, notes, expirationDateSubject.value, alertOption) else {
            preconditionFailure("Unable to create an item.")
        }

        isLoadingSubject.send(true)
        itemsWriteRepository.update(item)
    }

    public func remove() {
        isLoadingSubject.send(true)
        itemsWriteRepository.remove(item)
    }

    public func setLoading(_ isLoading: Bool) {
        isLoadingSubject.send(isLoading)
    }

    public func sendDisabledNotificationsMessage() {
        requestSubject.send(.showInfoMessage(
            .localized(.info),
            .localized(.disabledNotificationsMessage))
        )
    }

    private func bind() {
        $item
            .sink { [weak self] in self?.updateItem(with: $0) }
            .store(in: &subscriptions)

        thumbnails
            .dropFirst()
            .prefix(1)
            .sink { [weak self] in self?.originalPhotoIds = $0.map(\.id) }
            .store(in: &subscriptions)

        eventDispatcher.events
            .sink { [weak self] in
                self?.handleItemsEvent($0)
                self?.handlePhotosEvent($0)
                self?.handleOtherEvent($0)
            }
            .store(in: &subscriptions)
    }

    private func handleItemsEvent(_ event: AppEvent) {
        switch event {
        case let event as ItemUpdated:
            photosRepository.update(photosViewModel.photosChangeset, for: event.item)
        case is ItemsRemoved:
            requestSubject.send(.dismiss)
        case let event as ItemRemovedReceived where event.itemId == item.id:
            requestSubject.send(.dismiss)
        case let event as ItemUpdatedReceived where event.itemId == item.id:
            refreshItem()
        default:
            break
        }
    }

    private func handlePhotosEvent(_ event: AppEvent) {
        switch event {
        case let event as PhotosUpdated where event.itemId == item.id:
            requestSubject.send(.dismiss)
        case let event as PhotoAddedReceived where event.itemId == item.id:
            photosViewModel.fetchThumbnailIfNeeded(with: event.photoId)
        case let event as PhotoRemovedReceived where event.itemId == item.id:
            photosViewModel.removeThumbnailLocally(with: event.photoId)
        default:
            break
        }
    }

    private func handleOtherEvent(_ event: AppEvent) {
        switch event {
        case let event as AlertSet:
            alertOption = event.option
        case let event as ErrorOccured:
            isLoadingSubject.send(false)
            requestSubject.send(.showErrorMessage(event.error.localizedDescription))
        case is NoResultOccured:
            requestSubject.send(.dismiss)
        default:
            break
        }
    }

    private func refreshItem() {
        isLoadingSubject.send(true)
        itemsReadRepository.fetch(by: item.id)
            .sink { [weak self] in
                $0.map { self?.item = $0 }
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)
    }

    private func updateItem(with item: Item) {
        name = item.name
        notes = item.notes
        alertOption = item.alertOption

        if case .date(let date) = item.expiration {
            expirationDateSubject.send(date)
        } else {
            expirationDateSubject.send(nil)
        }
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func tryCreateItem(
        _ name: String,
        _ notes: String,
        _ expirationDate: Date?,
        _ alertOption: AlertOption
    ) -> Item? {
        guard !name.isEmpty else { return nil }

        return item
            .withName(name)
            .withNotes(notes)
            .withExpirationDate(expirationDate)
            .withAlertOption(alertOption)
    }
}

public extension EditItemViewModel {
    enum Request: Equatable {
        case dismiss
        case moveCurrentItem
        case removeCurrentItem
        case setAlert
        case showErrorMessage(_ message: String)
        case showInfoMessage(_ title: String, _ message: String)
    }
}
