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
        Publishers.CombineLatest4($name, $notes, expirationDateSubject, photosViewModel.photos)
            .map { [weak self] in (self?.originalItem, $0, $1, $2, $3) }
            .map { !$1.isEmpty && $0 != $0?.withName($1).withNotes($2).withExpirationDate($3).withPhotos($4) }
            .eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosCollectionViewModel

    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>

    private var originalItem: Item
    private let itemsService: ItemsService
    private let fileService: FileService
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, itemsService: ItemsService, fileService: FileService) {
        self.originalItem = item
        self.itemsService = itemsService
        self.fileService = fileService
        self.dateFormatter = .fullDateFormatter

        self.name = item.name
        self.notes = item.notes

        if case .date(let date) = item.expiration {
            self.expirationDateSubject = .init(date)
        } else {
            self.expirationDateSubject = .init(nil)
        }

        self.isExpirationDateVisibleSubject = .init(false)

        self.photosViewModel = .init(itemsService: itemsService, fileService: fileService)

        self.subscriptions = []

        self.bind()
        self.photosViewModel.fetchPhotos(forItem: originalItem)
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
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }

                return self.itemsService
                    .updatePhotos(self.photosViewModel.photosChangeset, forItem: item)
                    .eraseToAnyPublisher()
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
        photosViewModel.photos
            .prefix(2)
            .sink { [weak self] in
                guard let self = self else { return }
                self.originalItem = self.originalItem.withPhotos($0)
            }
            .store(in: &subscriptions)
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func tryCreateItem(_ name: String, _ notes: String, _ expirationDate: Date?) -> Item? {
        guard !name.isEmpty else { return nil }

        let photos = photosViewModel.createPhotos()

        if let expirationDate = expirationDate {
            let expiration = Expiration.date(expirationDate)
            return Item(id: originalItem.id, name: name, notes: notes, expiration: expiration, photos: photos)
        }

        return Item(id: originalItem.id, name: name, notes: notes, expiration: .none, photos: photos)
    }
}
