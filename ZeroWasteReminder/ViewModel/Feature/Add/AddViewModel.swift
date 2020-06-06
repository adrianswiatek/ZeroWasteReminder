import Combine
import UIKit

public final class AddViewModel {
    @Published public var name: String
    @Published public var notes: String
    @Published public var expirationTypeIndex: Int

    public var expirationType: AnyPublisher<ExpirationType, Never> {
        expirationTypeSubject.eraseToAnyPublisher()
    }

    public var photos: AnyPublisher<[UIImage], Never> {
        photosSubject.eraseToAnyPublisher()
    }

    public var canSaveItem: AnyPublisher<Bool, Never> {
        canSaveItemSubject.eraseToAnyPublisher()
    }

    public var needsCapturePhoto: AnyPublisher<Void, Never> {
        needsCapturePhotoSubject.eraseToAnyPublisher()
    }

    public var needsShowPhoto: AnyPublisher<UIImage, Never> {
        needsShowPhotoSubject.eraseToAnyPublisher()
    }

    public var needsRemovePhoto: AnyPublisher<Int, Never> {
        needsRemovePhotoSubject.eraseToAnyPublisher()
    }

    public var isExpirationDateVisible: Bool {
        expirationTypeIndex == ExpirationType.date.index
    }

    public var isExpirationPeriodVisible: Bool {
        expirationTypeIndex == ExpirationType.period.index
    }

    public let expirationDateViewModel: ExpirationDateViewModel
    public let expirationPeriodViewModel: ExpirationPeriodViewModel

    private let expirationTypeSubject: CurrentValueSubject<ExpirationType, Never>
    private let photosSubject: CurrentValueSubject<[UIImage], Never>
    private let canSaveItemSubject: CurrentValueSubject<Bool, Never>
    private let needsCapturePhotoSubject: PassthroughSubject<Void, Never>
    private let needsShowPhotoSubject: PassthroughSubject<UIImage, Never>
    private let needsRemovePhotoSubject: PassthroughSubject<Int, Never>

    private let itemsService: ItemsService
    private var subscriptions: Set<AnyCancellable>

    public init(itemsService: ItemsService) {
        self.itemsService = itemsService

        self.name = ""
        self.notes = ""

        self.expirationTypeIndex = ExpirationType.none.index

        self.expirationDateViewModel = .init(.init())
        self.expirationPeriodViewModel = .init(.day)

        self.photosSubject = .init([])
        self.expirationTypeSubject = .init(ExpirationType.none)
        self.canSaveItemSubject = .init(false)
        self.needsShowPhotoSubject = .init()
        self.needsRemovePhotoSubject = .init()
        self.needsCapturePhotoSubject = .init()

        self.subscriptions = []

        self.bind()
    }

    public func saveItem() -> Future<Void, ServiceError> {
        guard let item = createItem() else {
            preconditionFailure("Unable to create item.")
        }

        return itemsService.add(item)
    }

    public func addPhoto(_ photo: UIImage) {
        photosSubject.value.insert(photo, at: 0)
    }

    public func removePhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        photosSubject.value.remove(at: index)
    }

    private func bind() {
        expirationType.combineLatest(
            $name.map { !$0.isEmpty },
            expirationDateViewModel.isValid,
            expirationPeriodViewModel.isValid
        ) {
            switch $0 {
            case .none where $1:
                return true
            case .date where $2 && $1:
                return true
            case .period where $3 && $1:
                return true
            default:
                return false
            }
        }
        .subscribe(canSaveItemSubject)
        .store(in: &subscriptions)

        $expirationTypeIndex
            .map { ExpirationType.fromIndex($0) }
            .subscribe(expirationTypeSubject)
            .store(in: &subscriptions)
    }

    private func createItem() -> Item? {
        guard !name.isEmpty, let expiration = expirationForType(expirationTypeSubject.value) else {
            return nil
        }

        return Item(name: name, notes: notes, expiration: expiration)
    }

    private func expirationForType(_ expirationType: ExpirationType) -> Expiration? {
        switch expirationType {
        case .none: return Expiration.none
        case .date: return expirationDateViewModel.expiration
        case .period: return expirationPeriodViewModel.expiration
        }
    }
}

extension AddViewModel: PhotosCollectionHandler {
    public func setNeedsCapturePhoto() {
        needsCapturePhotoSubject.send()
    }

    public func setNeedsShowPhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsShowPhotoSubject.send(photosSubject.value[index])
    }

    public func setNeedsRemovePhoto(atIndex index: Int) {
        precondition(0 ..< photosSubject.value.count ~= index, "Index out of bounds.")
        needsRemovePhotoSubject.send(index)
    }
}
