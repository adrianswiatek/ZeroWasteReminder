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
        canSaveSubject.eraseToAnyPublisher()
    }

    public let photosViewModel: PhotosCollectionViewModel

    private let expirationDateSubject: CurrentValueSubject<Date?, Never>
    private let isExpirationDateVisibleSubject: CurrentValueSubject<Bool, Never>
    private let canSaveSubject: CurrentValueSubject<Bool, Never>

    private let originalItem: Item
    private let itemsService: ItemsService
    private let dateFormatter: DateFormatter

    private var subscriptions: Set<AnyCancellable>

    public init(item: Item, itemsService: ItemsService) {
        self.originalItem = item
        self.itemsService = itemsService
        self.dateFormatter = .fullDateFormatter

        self.name = item.name
        self.notes = item.notes

        if case .date(let date) = item.expiration {
            self.expirationDateSubject = .init(date)
        } else {
            self.expirationDateSubject = .init(nil)
        }

        self.isExpirationDateVisibleSubject = .init(false)
        self.canSaveSubject = .init(false)
        self.photosViewModel = .withPhotos([])

        self.subscriptions = []

        self.bind()
    }

    public func toggleExpirationDatePicker() {
        isExpirationDateVisibleSubject.value.toggle()
    }

    public func setExpirationDate(_ date: Date?) {
        expirationDateSubject.value = date
    }

    public func save() -> Future<Void, Never> {
        guard let item = tryCreateItem(name, notes, expirationDateSubject.value) else {
            preconditionFailure("Unable to create an item.")
        }

        return itemsService.update(item)
    }

    public func delete() -> Future<Void, ServiceError> {
        return itemsService.delete([originalItem])
    }

    private func bind() {
        Publishers.CombineLatest3($name, $notes, expirationDateSubject)
            .map { [weak self] in (self?.originalItem, $0, $1, $2) }
            .map { !$1.isEmpty && $0 != $0?.withName($1).withNotes($2).withExpirationDate($3) }
            .subscribe(canSaveSubject)
            .store(in: &subscriptions)
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }

    private func tryCreateItem(_ name: String, _ notes: String, _ expirationDate: Date?) -> Item? {
        guard !name.isEmpty else { return nil }

        if let expirationDate = expirationDate {
            return Item(id: originalItem.id, name: name, notes: notes, expiration: .date(expirationDate))
        }

        return Item(id: originalItem.id, name: name, notes: notes, expiration: .none)
    }
}
