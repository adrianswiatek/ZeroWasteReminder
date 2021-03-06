import Combine
import UIKit

public final class EditItemViewModel {
    @Published public var name: String
    @Published public var notes: String
    @Published public var item: Item

    public let requestSubject: PassthroughSubject<Request, Never>

    public var isLoading: AnyPublisher<Bool, Never> {
        isLoadingSubject.eraseToAnyPublisher()
    }

    public var expirationDate: AnyPublisher<(date: Date, formatted: String), Never> {
        expirationDateSubject
            .map { [weak self] in ($0 ?? Date(), self?.formattedDate($0) ?? "Toggle date picker") }
            .eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: AnyPublisher<Bool, Never> {
        isExpirationDateVisibleSubject.eraseToAnyPublisher()
    }

    public var isRemoveDateButtonEnabled: AnyPublisher<Bool, Never> {
        expirationDateSubject.map { $0 != nil }.eraseToAnyPublisher()
    }

    public var state: AnyPublisher<RemainingState, Never> {
        expirationDateSubject
            .map { $0 != nil ? Expiration.date($0!) : .none }
            .map { RemainingState(expiration: $0) }
            .eraseToAnyPublisher()
    }

    public var canSave: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(itemHasChanged, photoIdsHaveChanged)
            .map { $0 || $1 }
            .eraseToAnyPublisher()
    }

    public var canRemotelyConnect: AnyPublisher<Bool, Never> {
        statusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosViewModel

    private var itemHasChanged: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($name, $notes, expirationDateSubject)
            .map { [weak self] in (self?.item, $0, $1, $2) }
            .map { !$1.isEmpty && $0 != $0?.withName($1).withNotes($2).withExpirationDate($3) }
            .eraseToAnyPublisher()
    }

    private var photoIdsHaveChanged: AnyPublisher<Bool, Never> {
        photosViewModel.thumbnails
            .map { $0.map(\.id) }
            .map { [weak self] in $0 != self?.originalPhotoIds }
            .eraseToAnyPublisher()
    }

    private let isLoadingSubject: PassthroughSubject<Bool, Never>
    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>

    private var originalPhotoIds: [Id<Photo>]
    private let itemsRepository: ItemsRepository
    private let photosRepository: PhotosRepository
    private let fileService: FileService
    private let statusNotifier: StatusNotifier
    private let eventDispatcher: EventDispatcher
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

    public init(
        item: Item,
        itemsRepository: ItemsRepository,
        photosRepository: PhotosRepository,
        fileService: FileService,
        statusNotifier: StatusNotifier,
        eventDispatcher: EventDispatcher
    ) {
        self.itemsRepository = itemsRepository
        self.item = item
        self.originalPhotoIds = []
        self.photosRepository = photosRepository
        self.fileService = fileService
        self.statusNotifier = statusNotifier
        self.eventDispatcher = eventDispatcher
        self.dateFormatter = .fullDateFormatter

        self.name = ""
        self.notes = ""
        self.expirationDateSubject = .init(nil)

        self.requestSubject = .init()
        self.isLoadingSubject = .init()
        self.isExpirationDateVisibleSubject = .init(false)

        self.photosViewModel = .init(photosRepository: photosRepository, fileService: fileService)

        self.subscriptions = []

        self.bind()
        self.photosViewModel.fetchThumbnails(for: item)
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    public func saveItem() {
        guard let item = tryCreateItem(name, notes, expirationDateSubject.value) else {
            preconditionFailure("Unable to create an item.")
        }

        isLoadingSubject.send(true)
        itemsRepository.update(item)
    }

    public func remove() {
        isLoadingSubject.send(true)
        itemsRepository.remove(item)
    }

    public func cleanUp() {
        _ = fileService.removeTemporaryItems()
        isLoadingSubject.send(false)
    }

    private func bind() {
        $item
            .sink { [weak self] in self?.updateItem(with: $0) }
            .store(in: &subscriptions)

        photosViewModel.thumbnails
            .prefix(2)
            .sink { [weak self] in self?.originalPhotoIds = $0.map { $0.id } }
            .store(in: &subscriptions)

        eventDispatcher.events
            .compactMap { $0 as? ItemUpdated }
            .flatMap { [weak self] event -> AnyPublisher<Void, Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let changeset = self.photosViewModel.photosChangeset
                return self.photosRepository.update(changeset, for: event.item).eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] _ in self?.isLoadingSubject.send(false) },
                receiveValue: { [weak self] in self?.requestSubject.send(.dismiss) }
            )
            .store(in: &subscriptions)

        eventDispatcher.events
            .sink { [weak self] in
                self?.handleEvent($0)
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)
    }

    private func handleEvent(_ appEvent: AppEvent) {
        switch appEvent {
        case is ItemsRemoved:
            requestSubject.send(.dismiss)
        case let event as ItemRemovedReceived where event.itemId == item.id:
            requestSubject.send(.dismiss)
        case let event as ItemUpdatedReceived where event.itemId == item.id:
            refreshItem()
        default:
            return
        }
    }

    private func refreshItem() {
        isLoadingSubject.send(true)
        itemsRepository.fetch(by: item.id)
            .sink { [weak self] in
                $0.map { self?.item = $0 }
                self?.isLoadingSubject.send(false)
            }
            .store(in: &subscriptions)
    }

    private func updateItem(with item: Item) {
        name = item.name
        notes = item.notes

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

    private func tryCreateItem(_ name: String, _ notes: String, _ expirationDate: Date?) -> Item? {
        guard !name.isEmpty else { return nil }
        return item.withName(name).withNotes(notes).withExpirationDate(expirationDate)
    }
}

public extension EditItemViewModel {
    enum Request: Equatable {
        case dismiss
        case moveCurrentItem
        case removeCurrentItem
    }
}
