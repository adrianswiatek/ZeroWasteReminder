import Combine
import UIKit

public final class EditViewModel {
    @Published var name: String
    @Published var notes: String

    public var expirationDate: AnyPublisher<(date: Date, formatted: String), Never> {
        expirationDateSubject
            .map { [weak self] in ($0 ?? Date(), self?.formattedDate($0) ?? "Toggle date picker") }
            .eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: AnyPublisher<Bool, Never>  {
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
        remoteStatusNotifier.remoteStatus.map { $0 == .connected }.eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosViewModel

    private var itemHasChanged: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($name, $notes, expirationDateSubject)
            .map { [weak self] in (self?.originalItem, $0, $1, $2) }
            .map { !$1.isEmpty && $0 != $0?.withName($1).withNotes($2).withExpirationDate($3) }
            .eraseToAnyPublisher()
    }

    private var photoIdsHaveChanged: AnyPublisher<Bool, Never> {
        photosViewModel.thumbnails
            .map { $0.map(\.id) }
            .map { [weak self] in $0 != self?.originalPhotoIds }
            .eraseToAnyPublisher()
    }

    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>

    private let originalItem: Item
    private var originalPhotoIds: [UUID]
    private let itemsService: ItemsService
    private let photosService: PhotosService
    private let fileService: FileService
    private let remoteStatusNotifier: RemoteStatusNotifier
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

    public init(
        item: Item,
        itemsService: ItemsService,
        photosService: PhotosService,
        fileService: FileService,
        remoteStatusNotifier: RemoteStatusNotifier
    ) {
        self.originalItem = item
        self.originalPhotoIds = []
        self.itemsService = itemsService
        self.photosService = photosService
        self.fileService = fileService
        self.remoteStatusNotifier = remoteStatusNotifier
        self.dateFormatter = .fullDateFormatter

        self.name = item.name
        self.notes = item.notes

        if case .date(let date) = item.expiration {
            self.expirationDateSubject = .init(date)
        } else {
            self.expirationDateSubject = .init(nil)
        }

        self.isExpirationDateVisibleSubject = .init(false)

        self.photosViewModel = .init(
            photosService: photosService,
            itemsService: itemsService,
            fileService: fileService
        )

        self.subscriptions = []

        self.bind()
        self.photosViewModel.fetchThumbnails(for: originalItem)
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    public func save() -> AnyPublisher<Void, ServiceError> {
        guard let item = tryCreateItem(name, notes, expirationDateSubject.value) else {
            preconditionFailure("Unable to create an item.")
        }

        return itemsService.update(item)
            .flatMap { [weak self] () -> AnyPublisher<Void, ServiceError> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                let changeset = self.photosViewModel.photosChangeset
                return self.photosService.update(changeset, for: item).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public func delete() -> Future<Void, ServiceError> {
        return itemsService.delete([originalItem])
    }

    public func cleanUp() {
        _ = fileService.removeTemporaryItems()
    }

    private func bind() {
        photosViewModel.thumbnails
            .prefix(2)
            .sink { [weak self] in self?.originalPhotoIds = $0.map { $0.id } }
            .store(in: &subscriptions)
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func tryCreateItem(_ name: String, _ notes: String, _ expirationDate: Date?) -> Item? {
        guard !name.isEmpty else { return nil }

        if let expirationDate = expirationDate {
            let expiration = Expiration.date(expirationDate)
            return Item(id: originalItem.id, name: name, notes: notes, expiration: expiration)
        }

        return Item(id: originalItem.id, name: name, notes: notes, expiration: .none)
    }
}
