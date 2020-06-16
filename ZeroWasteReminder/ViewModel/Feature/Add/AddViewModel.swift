import Combine
import UIKit

public final class AddViewModel {
    @Published public var name: String
    @Published public var notes: String
    @Published public var expirationTypeIndex: Int

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

    public let photosViewModel: PhotosCollectionViewModel
    public let expirationDateViewModel: ExpirationDateViewModel
    public let expirationPeriodViewModel: ExpirationPeriodViewModel

    private let expirationTypeSubject: CurrentValueSubject<ExpirationType, Never>

    private let itemsService: ItemsService
    private let fileService: FileService
    private var subscriptions: Set<AnyCancellable>

    public init(itemsService: ItemsService, fileService: FileService) {
        self.itemsService = itemsService
        self.fileService = fileService

        self.name = ""
        self.notes = ""

        self.expirationTypeIndex = ExpirationType.none.index

        self.photosViewModel = .init(itemsService: itemsService, fileService: fileService)
        self.expirationDateViewModel = .init(.init())
        self.expirationPeriodViewModel = .init(.day)

        self.expirationTypeSubject = .init(ExpirationType.none)

        self.subscriptions = []

        self.bind()
    }

    public func saveItem() -> Future<Void, ServiceError> {
        guard let item = createItem() else {
            preconditionFailure("Unable to create item.")
        }

        return itemsService.add(item)
    }

    public func cleanUp() {
        _ = fileService.removeTemporaryItems()
    }

    private func bind() {
        $expirationTypeIndex
            .map { ExpirationType.fromIndex($0) }
            .sink { [weak self] in self?.expirationTypeSubject.send($0) }
            .store(in: &subscriptions)
    }

    private func createItem() -> Item? {
        guard !name.isEmpty, let expiration = expiration() else {
            return nil
        }

        return Item(name: name, notes: notes, expiration: expiration, photos: photosViewModel.createPhotos())
    }

    private func expiration() -> Expiration? {
        switch expirationTypeSubject.value {
        case .none: return Expiration.none
        case .date: return expirationDateViewModel.expiration
        case .period: return expirationPeriodViewModel.expiration
        }
    }
}
